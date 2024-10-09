if Config.EnableESXService and Config.MaxInService ~= -1 then
	TriggerEvent('esx_service:activateService', 'police', Config.MaxInService)
end

TriggerEvent('esx_phone:registerNumber', 'police', TranslateCap('alert_police'), true, true)
TriggerEvent('esx_society:registerSociety', 'police', TranslateCap('society_police'), 'society_police', 'society_police', 'society_police', {type = 'public'})

RegisterNetEvent('esx_policejob:confiscatePlayerItem', function(target, itemType, itemName, amount)
	local source = source
	local sourceXPlayer = ESX.GetPlayerFromId(source)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if sourceXPlayer.job.name ~= 'police' then
		return print(('[^3WARNING^7] Player ^5%s^7 Attempted To Exploit The Confuscation System!'):format(sourceXPlayer.source))
	end

	if itemType == 'item_standard' then
		local targetItem = targetXPlayer.getInventoryItem(itemName)
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)

		-- can the player carry the said amount of x item?
		-- does the target player have enough in their inventory?
		if (targetItem.count < 0 or targetItem.count > amount) or (not sourceXPlayer.canCarryItem(itemName, sourceItem.count)) then
			return sourceXPlayer.showNotification(TranslateCap('quantity_invalid'))
		end

		targetXPlayer.removeInventoryItem(itemName, amount)
		sourceXPlayer.addInventoryItem   (itemName, amount)
		sourceXPlayer.showNotification(TranslateCap('you_confiscated', amount, sourceItem.label, targetXPlayer.name))
		targetXPlayer.showNotification(TranslateCap('got_confiscated', amount, sourceItem.label, sourceXPlayer.name))
	elseif itemType == 'item_account' then
		local targetAccount = targetXPlayer.getAccount(itemName)

		-- does the target player have enough money?
		if targetAccount.money < amount then
			return sourceXPlayer.showNotification(TranslateCap('quantity_invalid'))
		end
		 
		targetXPlayer.removeAccountMoney(itemName, amount, "Confiscated")
		sourceXPlayer.addAccountMoney   (itemName, amount, "Confiscated")

		sourceXPlayer.showNotification(TranslateCap('you_confiscated_account', amount, itemName, targetXPlayer.name))
		targetXPlayer.showNotification(TranslateCap('got_confiscated_account', amount, itemName, sourceXPlayer.name))
		
	elseif itemType == 'item_weapon' then
		if amount == nil then amount = 0 end

		-- does the target player have weapon?
		if not targetXPlayer.hasWeapon(itemName) then
			return sourceXPlayer.showNotification(TranslateCap('quantity_invalid'))
		end

		targetXPlayer.removeWeapon(itemName)
		sourceXPlayer.addWeapon   (itemName, amount)

		sourceXPlayer.showNotification(TranslateCap('you_confiscated_weapon', ESX.GetWeaponLabel(itemName), targetXPlayer.name, amount))
		targetXPlayer.showNotification(TranslateCap('got_confiscated_weapon', ESX.GetWeaponLabel(itemName), amount, sourceXPlayer.name))
	end
end)

RegisterNetEvent('esx_policejob:handcuff', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name ~= 'police' then
		return print(('[^3WARNING^7] Player ^5%s^7 Attempted To Exploit Handcuffs!'):format(xPlayer.source))
	end

	TriggerClientEvent('esx_policejob:handcuff', target)
end)

RegisterNetEvent('esx_policejob:drag', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name ~= 'police' then
		return print(('[^3WARNING^7] Player ^5%s^7 Attempted To Exploit Dragging!'):format(xPlayer.source))
	end

	TriggerClientEvent('esx_policejob:drag', target, source)
end)

RegisterNetEvent('esx_policejob:putInVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name ~= 'police' then
		return print(('[^3WARNING^7] Player ^5%s^7 Attempted To Exploit Garage!'):format(xPlayer.source))
	end

	TriggerClientEvent('esx_policejob:putInVehicle', target)
end)

RegisterNetEvent('esx_policejob:OutVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.job.name ~= 'police' then
		return print(('[^3WARNING^7] Player ^5%s^7 Attempted To Exploit Dragging Out Of Vehicle!'):format(xPlayer.source))
	end 

	TriggerClientEvent('esx_policejob:OutVehicle', target)
end)

RegisterNetEvent('esx_policejob:getStockItem', function(itemName, count)
	local source = source
	local xPlayer = ESX.GetPlayerFromId(source)

	if count < 0 then return xPlayer.showNotification(TranslateCap('quantity_invalid')) end 

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_police', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- is there enough in the society?
		-- can the player carry the said amount of x item?
		if inventoryItem.count < count or (not xPlayer.canCarryItem(itemName, count)) then return xPlayer.showNotification(TranslateCap('quantity_invalid')) end

		inventory.removeItem(itemName, count)
		xPlayer.addInventoryItem(itemName, count)
		xPlayer.showNotification(TranslateCap('have_withdrawn', count, inventoryItem.name))
	end)
end)

RegisterNetEvent('esx_policejob:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem(itemName)

	if count < 0 then return xPlayer.showNotification(TranslateCap('quantity_invalid')) end 

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_police', function(inventory)
		local inventoryItem = inventory.getItem(itemName)

		-- does the player have enough of the item?
		if sourceItem.count < count then return xPlayer.showNotification(TranslateCap('quantity_invalid')) end 

		xPlayer.removeInventoryItem(itemName, count)
		inventory.addItem(itemName, count)
		xPlayer.showNotification(TranslateCap('have_deposited', count, inventoryItem.name))
	end)
end)

ESX.RegisterServerCallback('esx_policejob:getOtherPlayerData', function(source, cb, target, notify)
	local xPlayer = ESX.GetPlayerFromId(target)

	if notify then
		xPlayer.showNotification(TranslateCap('being_searched'))
	end

	if not xPlayer then return end 
	local data = {
		name = xPlayer.getName(),
		job = xPlayer.job.label,
		grade = xPlayer.job.grade_label,
		inventory = xPlayer.getInventory(),
		accounts = xPlayer.getAccounts(),
		weapons = xPlayer.getLoadout()
	}

	if Config.EnableESXIdentity then
		data.dob = xPlayer.get('dateofbirth')
		data.height = xPlayer.get('height')

		if xPlayer.get('sex') == 'm' then data.sex = 'male' else data.sex = 'female' end
	end

	TriggerEvent('esx_status:getStatus', target, 'drunk', function(status)
		if status then
			data.drunk = ESX.Math.Round(status.percent)
		end
	end)

	if not Config.EnableLicenses then
		return cb(data)
	end

	TriggerEvent('esx_license:getLicenses', target, function(licenses)
		data.licenses = licenses
		cb(data)
	end)
end)

local fineList = {}
ESX.RegisterServerCallback('esx_policejob:getFineList', function(source, cb, category)
	if fineList[category] then
		return cb(fineList[category])
	end

	MySQL.query('SELECT * FROM fine_types WHERE category = ?', {category},
	function(fines)
		fineList[category] = fines
		cb(fines)
	end)
end)

ESX.RegisterServerCallback('esx_policejob:getVehicleInfos', function(source, cb, plate)
	local retrievedInfo = {
		plate = plate
	}
	if Config.EnableESXIdentity then
		MySQL.single('SELECT users.firstname, users.lastname FROM owned_vehicles JOIN users ON owned_vehicles.owner = users.identifier WHERE plate = ?', {plate},
		function(result)
			if result then
				retrievedInfo.owner = ('%s %s'):format(result.firstname, result.lastname)
			end
			cb(retrievedInfo)
		end)
	else
		MySQL.scalar('SELECT owner FROM owned_vehicles WHERE plate = ?', {plate},
		function(owner)
			if owner then
				local xPlayer = ESX.GetPlayerFromIdentifier(owner)
				if xPlayer then
					retrievedInfo.owner = xPlayer.getName()
				end
			end
			cb(retrievedInfo)
		end)
	end
end)

ESX.RegisterServerCallback('esx_policejob:getArmoryWeapons', function(source, cb)
	TriggerEvent('esx_datastore:getSharedDataStore', 'society_police', function(store)
		local weapons = store.get('weapons')

		if weapons == nil then
			weapons = {}
		end

		cb(weapons)
	end)
end)

ESX.RegisterServerCallback('esx_policejob:addArmoryWeapon', function(source, cb, weaponName, removeWeapon)
	local xPlayer = ESX.GetPlayerFromId(source)

	if removeWeapon then
		xPlayer.removeWeapon(weaponName)
	end

	TriggerEvent('esx_datastore:getSharedDataStore', 'society_police', function(store)
		local weapons = store.get('weapons') or {}
		local foundWeapon = false

		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = weapons[i].count + 1
				foundWeapon = true
				break
			end
		end

		if not foundWeapon then
			table.insert(weapons, {
				name  = weaponName,
				count = 1
			})
		end

		store.set('weapons', weapons)
		cb()
	end)
end)

ESX.RegisterServerCallback('esx_policejob:removeArmoryWeapon', function(source, cb, weaponName)
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.addWeapon(weaponName, 500)

	TriggerEvent('esx_datastore:getSharedDataStore', 'society_police', function(store)
		local weapons = store.get('weapons') or {}

		local foundWeapon = false

		for i=1, #weapons, 1 do
			if weapons[i].name == weaponName then
				weapons[i].count = (weapons[i].count > 0 and weapons[i].count - 1 or 0)
				foundWeapon = true
				break
			end
		end

		if not foundWeapon then
			table.insert(weapons, {
				name = weaponName,
				count = 0
			})
		end

		store.set('weapons', weapons)
		cb()
	end)
end)

ESX.RegisterServerCallback('esx_policejob:buyWeapon', function(source, cb, weaponName, type, componentNum)
	local xPlayer = ESX.GetPlayerFromId(source)
	local authorizedWeapons, selectedWeapon = Config.AuthorizedWeapons[xPlayer.job.grade_name]

	for k,v in ipairs(authorizedWeapons) do
		if v.weapon == weaponName then
			selectedWeapon = v
			break
		end
	end

	if not selectedWeapon then
		print(('[^3WARNING^7] Player ^5%s^7 Attempted To Buy Invalid Weapon - ^5%s^7!'):format(source, weaponName))
		return cb(false)
	end 
		-- Weapon
	if type == 1 then
		if xPlayer.getMoney() < selectedWeapon.price then 
			return cb(false) 
		end

		xPlayer.removeMoney(selectedWeapon.price, "Weapon Bought")
		xPlayer.addWeapon(weaponName, 100)

		cb(true)
	-- Weapon Component
	elseif type == 2 then
		local price = selectedWeapon.components[componentNum]
		local weaponNum, weapon = ESX.GetWeapon(weaponName)
		local component = weapon.components[componentNum]

		if not component then
			print(('[^3WARNING^7] Player ^5%s^7 Attempted To Buy Invalid Weapon Component - ^5%s^7!'):format(source, componentNum))
			cb(false)
		end

		if xPlayer.getMoney() < price then 
			return cb(false) 
		end

		xPlayer.removeMoney(price, "Weapon Component Bought")
		xPlayer.addWeaponComponent(weaponName, component.name)

		cb(true)
	end
end)

ESX.RegisterServerCallback('esx_policejob:buyJobVehicle', function(source, cb, vehicleProps, type)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = getPriceFromHash(vehicleProps.model, xPlayer.job.grade_name, type)

	-- vehicle model not found
	if price == 0 then
		print(('[^3WARNING^7] Player ^5%s^7 Attempted To Buy Invalid Vehicle - ^5%s^7!'):format(source, vehicleProps.model))
		return cb(false)
	end

	if xPlayer.getMoney < price then 
		return cb(false) 
	end

	xPlayer.removeMoney(price, "Job Vehicle Bought")
	MySQL.insert('INSERT INTO owned_vehicles (owner, vehicle, plate, type, job, `stored`) VALUES (?, ?, ?, ?, ?, ?)', { xPlayer.identifier, json.encode(vehicleProps), vehicleProps.plate, type, xPlayer.job.name, true},
	function (rowsChanged)
		cb(rowsChanged > 0)
	end)

end)

ESX.RegisterServerCallback('esx_policejob:storeNearbyVehicle', function(source, cb, plates)
	local xPlayer = ESX.GetPlayerFromId(source)

	local plate = MySQL.scalar.await('SELECT plate FROM owned_vehicles WHERE owner = ? AND plate IN (?) AND job = ?', {xPlayer.identifier, plates, xPlayer.job.name})

	if not plate then return cb(false) end
	MySQL.update('UPDATE owned_vehicles SET `stored` = true WHERE owner = ? AND plate = ? AND job = ?', {xPlayer.identifier, plate, xPlayer.job.name},
	function(rowsChanged)
		cb(rowsChanged > 0 and plate)
	end)
end)

function getPriceFromHash(vehicleHash, jobGrade, type)
	local vehicles = Config.AuthorizedVehicles[type][jobGrade]

	for i = 1, #vehicles do
		local vehicle = vehicles[i]
		if GetHashKey(vehicle.model) == vehicleHash then
			return vehicle.price
		end
	end

	return 0
end

ESX.RegisterServerCallback('esx_policejob:getStockItems', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_police', function(inventory)
		cb(inventory.items)
	end)
end)

ESX.RegisterServerCallback('esx_policejob:getPlayerInventory', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local items   = xPlayer.inventory

	cb({items = items})
end)

AddEventHandler('onResourceStop', function(resource)
	if resource ~= GetCurrentResourceName() then return end 
	TriggerEvent('esx_phone:removeNumber', 'police')
end)
