local CurrentActionData, handcuffTimer, dragStatus, blipsCops = {}, {}, {}, {}
local HasAlreadyEnteredMarker, isDead, isHandcuffed, hasAlreadyJoined, playerInService = false, false, false, false, false
local LastStation, LastPart, LastPartNum, LastEntity, CurrentAction, CurrentActionMsg
dragStatus.isDragged, isInShopMenu = false, false
LocalPlayer.state:set("handcuffed", isHandcuffed, true)
LocalPlayer.state:set("handcuffAnim", false, true)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

function cleanPlayer(playerPed)
	SetPedArmour(playerPed, 0)
	ClearPedBloodDamage(playerPed)
	ResetPedVisibleDamage(playerPed)
	ClearPedLastWeaponDamage(playerPed)
	ResetPedMovementClipset(playerPed, 0)
end

function setUniform(uniform, playerPed)
	TriggerEvent('skinchanger:getSkin', function(skin)
		local uniformObject

		if skin.sex == 0 then
			uniformObject = Config.Uniforms[uniform].male
		else
			uniformObject = Config.Uniforms[uniform].female
		end

		if uniformObject then
			TriggerEvent('skinchanger:loadClothes', skin, uniformObject)

			if uniform == 'bullet_wear' then
				SetPedArmour(playerPed, 100)
			end
		else
			ESX.ShowNotification(TranslateCap('no_outfit'))
		end
	end)
end

function OpenCloakroomMenu()
	local playerPed = PlayerPedId()
	local grade = ESX.PlayerData.job.grade_name

	local elements = {
		{unselectable = true, icon = "fas fa-shirt", title = TranslateCap("cloakroom")},
		{icon = "fas fa-shirt", title = TranslateCap('citizen_wear'), value = 'citizen_wear'},
		{icon = "fas fa-shirt", title = TranslateCap('bullet_wear'), uniform = 'bullet_wear'},
		{icon = "fas fa-shirt", title = TranslateCap('gilet_wear'), uniform = 'gilet_wear'},
		{icon = "fas fa-shirt", title = TranslateCap('police_wear'), uniform = grade}
	}

	if Config.EnableCustomPeds then
		for k,v in ipairs(Config.CustomPeds.shared) do
			elements[#elements+1] = {
				icon = "fas fa-shirt",
				title = v.label, 
				value = 'freemode_ped', 
				maleModel = v.maleModel, 
				femaleModel = v.femaleModel
			}
		end

		for k,v in ipairs(Config.CustomPeds[grade]) do
			elements[#elements+1] = {
				icon = "fas fa-shirt",
				title = v.label, 
				value = 'freemode_ped', 
				maleModel = v.maleModel, 
				femaleModel = v.femaleModel
			}
		end
	end

	ESX.OpenContext("right", elements, function(menu,element)
		cleanPlayer(playerPed)
		local data = {current = element}

		if data.current.value == 'citizen_wear' then
			if Config.EnableCustomPeds then
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					local isMale = skin.sex == 0

					TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
						ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
							TriggerEvent('skinchanger:loadSkin', skin)
							TriggerEvent('esx:restoreLoadout')
						end)
					end)

				end)
			else
				ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
					TriggerEvent('skinchanger:loadSkin', skin)
				end)
			end

			if Config.EnableESXService then
				ESX.TriggerServerCallback('esx_service:isInService', function(isInService)
					if isInService then
						playerInService = false

						local notification = {
							title    = TranslateCap('service_anonunce'),
							subject  = '',
							msg      = TranslateCap('service_out_announce', GetPlayerName(PlayerId())),
							iconType = 1
						}

						TriggerServerEvent('esx_service:notifyAllInService', notification, 'police')

						TriggerServerEvent('esx_service:disableService', 'police')
						TriggerEvent('esx_policejob:updateBlip')
						ESX.ShowNotification(TranslateCap('service_out'))
					end
				end, 'police')
			end
		end

		if Config.EnableESXService and data.current.value ~= 'citizen_wear' then
			local awaitService

			ESX.TriggerServerCallback('esx_service:isInService', function(isInService)
				if not isInService then

					if Config.MaxInService ~= -1 then
						ESX.TriggerServerCallback('esx_service:enableService', function(canTakeService, maxInService, inServiceCount)
							if not canTakeService then
								ESX.ShowNotification(TranslateCap('service_max', inServiceCount, maxInService))
							else
								awaitService = true
								playerInService = true

								local notification = {
									title    = TranslateCap('service_anonunce'),
									subject  = '',
									msg      = TranslateCap('service_in_announce', GetPlayerName(PlayerId())),
									iconType = 1
								}

								TriggerServerEvent('esx_service:notifyAllInService', notification, 'police')
								TriggerEvent('esx_policejob:updateBlip')
								ESX.ShowNotification(TranslateCap('service_in'))
							end
						end, 'police')
					else
						awaitService = true
						playerInService = true

						local notification = {
							title    = TranslateCap('service_anonunce'),
							subject  = '',
							msg      = TranslateCap('service_in_announce', GetPlayerName(PlayerId())),
							iconType = 1
						}

						TriggerServerEvent('esx_service:notifyAllInService', notification, 'police')
						TriggerEvent('esx_policejob:updateBlip')
						ESX.ShowNotification(TranslateCap('service_in'))
					end

				else
					awaitService = true
				end
			end, 'police')

			while awaitService == nil do
				Wait(0)
			end

			-- if we couldn't enter service don't let the player get changed
			if not awaitService then
				return
			end
		end

		if data.current.uniform then
			setUniform(data.current.uniform, playerPed)
		elseif data.current.value == 'freemode_ped' then
			local modelHash

			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				if skin.sex == 0 then
					modelHash = joaat(data.current.maleModel)
				else
					modelHash = joaat(data.current.femaleModel)
				end

				ESX.Streaming.RequestModel(modelHash, function()
					SetPlayerModel(PlayerId(), modelHash)
					SetModelAsNoLongerNeeded(modelHash)
					SetPedDefaultComponentVariation(PlayerPedId())

					TriggerEvent('esx:restoreLoadout')
				end)
			end)
		end
	end, function(menu)
		CurrentAction     = 'menu_cloakroom'
		CurrentActionMsg  = TranslateCap('open_cloackroom')
		CurrentActionData = {}
	end)
end

function OpenArmoryMenu(station)
	local elements
	if Config.OxInventory then
		exports.ox_inventory:openInventory('stash', {id = 'society_police', owner = station})
		return ESX.CloseContext()
	else
		elements = {
			{unselectable = true, icon = "fas fa-gun", title = TranslateCap('armory')},
			{icon = "fas fa-gun", title = TranslateCap('buy_weapons'), value = 'buy_weapons'}
		}

		if Config.EnableArmoryManagement then
			table.insert(elements, {icon = "fas fa-gun", title = TranslateCap('get_weapon'),     value = 'get_weapon'})
			table.insert(elements, {icon = "fas fa-gun", title = TranslateCap('put_weapon'),     value = 'put_weapon'})
			table.insert(elements, {icon = "fas fa-box", title = TranslateCap('remove_object'),  value = 'get_stock'})
			table.insert(elements, {icon = "fas fa-box", title = TranslateCap('deposit_object'), value = 'put_stock'})
		end
	end

	ESX.OpenContext("right", elements, function(menu,element)
		local data = {current = element}
		if data.current.value == 'get_weapon' then
			OpenGetWeaponMenu()
		elseif data.current.value == 'put_weapon' then
			OpenPutWeaponMenu()
		elseif data.current.value == 'buy_weapons' then
			OpenBuyWeaponsMenu()
		elseif data.current.value == 'put_stock' then
			OpenPutStocksMenu()
		elseif data.current.value == 'get_stock' then
			OpenGetStocksMenu()
		end
	end, function(menu)
		CurrentAction     = 'menu_armory'
		CurrentActionMsg  = TranslateCap('open_armory')
		CurrentActionData = {station = station}
	end)
end

function ShowPlayerLicense(player)
	local elements = {
		{unselectable = true, icon = "fas fa-scroll", title = TranslateCap('license_revoke')}
	}

	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(playerData)
		if playerData.licenses then
			for i=1, #playerData.licenses, 1 do
				if playerData.licenses[i].label and playerData.licenses[i].type then
					elements[#elements+1] = {
						icon = "fas fa-scroll",
						title = playerData.licenses[i].label,
						type = playerData.licenses[i].type
					}
				end
			end
		end

		ESX.OpenContext("right", elements, function(menu,element)
			local data = {current = element}
			ESX.ShowNotification(TranslateCap('licence_you_revoked', data.current.label, playerData.name))
			TriggerServerEvent('esx_policejob:message', GetPlayerServerId(player), TranslateCap('license_revoked', data.current.label))

			TriggerServerEvent('esx_license:removeLicense', GetPlayerServerId(player), data.current.type)

			ESX.SetTimeout(300, function()
				ShowPlayerLicense(player)
			end)
		end)
	end, GetPlayerServerId(player))
end

function OpenUnpaidBillsMenu(player)
	local elements = {
		{unselectable = true, icon = "fas fa-scroll", title = TranslateCap('unpaid_bills')}
	}

	ESX.TriggerServerCallback('esx_billing:getTargetBills', function(bills)
		for k,bill in ipairs(bills) do
			elements[#elements+1] = {
				unselectable = true,
				icon = "fas fa-scroll",
				title = ('%s - <span style="color:red;">%s</span>'):format(bill.label, TranslateCap('armory_item', ESX.Math.GroupDigits(bill.amount))),
				billId = bill.id
			}
		end

		ESX.OpenContext("right", elements, nil, nil)
	end, GetPlayerServerId(player))
end

function OpenGetWeaponMenu()
	ESX.TriggerServerCallback('esx_policejob:getArmoryWeapons', function(weapons)
		local elements = {
			{unselectable = true, icon = "fas fa-gun", title = TranslateCap('get_weapon_menu')}
		}

		for i=1, #weapons, 1 do
			if weapons[i].count > 0 then
				elements[#elements+1] = {
					icon = "fas fa-gun",
					title = 'x' .. weapons[i].count .. ' ' .. ESX.GetWeaponLabel(weapons[i].name),
					value = weapons[i].name
				}
			end
		end

		ESX.OpenContext("right", elements, function(menu,element)
			local data = {current = element}
			ESX.TriggerServerCallback('esx_policejob:removeArmoryWeapon', function()
				ESX.CloseContext()
				OpenGetWeaponMenu()
			end, data.current.value)
		end)
	end)
end

function OpenPutWeaponMenu()
	local elements   = {
		{unselectable = true, icon = "fas fa-gun", title = TranslateCap('put_weapon_menu')}
	}
	local playerPed  = PlayerPedId()
	local weaponList = ESX.GetWeaponList()

	for i=1, #weaponList, 1 do
		local weaponHash = joaat(weaponList[i].name)

		if HasPedGotWeapon(playerPed, weaponHash, false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
			elements[#elements+1] = {
				icon = "fas fa-gun",
				title = weaponList[i].label,
				value = weaponList[i].name
			}
		end
	end

	ESX.OpenContext("right", elements, function(menu,element)
		local data = {current = element}
		ESX.TriggerServerCallback('esx_policejob:addArmoryWeapon', function()
			ESX.CloseContext()
			OpenPutWeaponMenu()
		end, data.current.value, true)
	end)
end

function OpenBuyWeaponsMenu()
	local elements = {
		{unselectable = true, icon = "fas fa-gun", title = TranslateCap('armory_weapontitle')}
	}
	local playerPed = PlayerPedId()

	for k,v in ipairs(Config.AuthorizedWeapons[ESX.PlayerData.job.grade_name]) do
		local weaponNum, weapon = ESX.GetWeapon(v.weapon)
		local components, label = {}
		local hasWeapon = HasPedGotWeapon(playerPed, joaat(v.weapon), false)

		if v.components then
			for i=1, #v.components do
				if v.components[i] then
					local component = weapon.components[i]
					local hasComponent = HasPedGotWeaponComponent(playerPed, joaat(v.weapon), component.hash)

					if hasComponent then
						label = ('%s: <span style="color:green;">%s</span>'):format(component.label, TranslateCap('armory_owned'))
					else
						if v.components[i] > 0 then
							label = ('%s: <span style="color:green;">%s</span>'):format(component.label, TranslateCap('armory_item', ESX.Math.GroupDigits(v.components[i])))
						else
							label = ('%s: <span style="color:green;">%s</span>'):format(component.label, TranslateCap('armory_free'))
						end
					end

					components[#components+1] = {
						icon = "fas fa-gun",
						title = label,
						componentLabel = component.label,
						hash = component.hash,
						name = component.name,
						price = v.components[i],
						hasComponent = hasComponent,
						componentNum = i
					}
				end
			end
		end

		if hasWeapon and v.components then
			label = ('%s: <span style="color:green;">></span>'):format(weapon.label)
		elseif hasWeapon and not v.components then
			label = ('%s: <span style="color:green;">%s</span>'):format(weapon.label, TranslateCap('armory_owned'))
		else
			if v.price > 0 then
				label = ('%s: <span style="color:green;">%s</span>'):format(weapon.label, TranslateCap('armory_item', ESX.Math.GroupDigits(v.price)))
			else
				label = ('%s: <span style="color:green;">%s</span>'):format(weapon.label, TranslateCap('armory_free'))
			end
		end

		elements[#elements+1] = {
			icon = "fas fa-gun",
			title = label,
			weaponLabel = weapon.label,
			name = weapon.name,
			components = components,
			price = v.price,
			hasWeapon = hasWeapon
		}
	end

	ESX.OpenContext("right", elements, function(menu,element)
		local data = {current = element}
		if data.current.hasWeapon then
			if #data.current.components > 0 then
				OpenWeaponComponentShop(data.current.components, data.current.name, menu)
			end
		else
			ESX.TriggerServerCallback('esx_policejob:buyWeapon', function(bought)
				if bought then
					if data.current.price > 0 then
						ESX.ShowNotification(TranslateCap('armory_bought', data.current.weaponLabel, ESX.Math.GroupDigits(data.current.price)))
					end

					menu.close()
					OpenBuyWeaponsMenu()
				else
					ESX.ShowNotification(TranslateCap('armory_money'))
				end
			end, data.current.name, 1)
		end
	end)
end

function OpenWeaponComponentShop(components, weaponName, parentShop)

	ESX.OpenContext("right", components, function(menu,element)
		local data = {current = element}
		if data.current.hasComponent then
			ESX.ShowNotification(TranslateCap('armory_hascomponent'))
		else
			ESX.TriggerServerCallback('esx_policejob:buyWeapon', function(bought)
				if bought then
					if data.current.price > 0 then
						ESX.ShowNotification(TranslateCap('armory_bought', data.current.componentLabel, ESX.Math.GroupDigits(data.current.price)))
					end

					menu.close()
					parentShop.close()
					OpenBuyWeaponsMenu()
				else
					ESX.ShowNotification(TranslateCap('armory_money'))
				end
			end, weaponName, 2, data.current.componentNum)
		end
	end)
end

function OpenGetStocksMenu()
	ESX.TriggerServerCallback('esx_policejob:getStockItems', function(items)
		local elements = {
			{unselectable = true, icon = "fas fa-box", title = TranslateCap('police_stock')}
		}

		for i=1, #items, 1 do
			elements[#elements+1] = {
				icon = "fas fa-box",
				title = 'x' .. items[i].count .. ' ' .. items[i].label,
				value = items[i].name
			}
		end

		ESX.OpenContext("right", elements, function(menu,element)
			local data = {current = element}
			local itemName = data.current.value

			local elements2 = {
				{unselectable = true, icon = "fas fa-box", title = element.title},
				{title = TranslateCap('quantity'), input = true, inputType = "number", inputMin = 1, inputMax = 150, inputPlaceholder = "Amount to withdraw.."},
				{icon = "fas fa-check-double", title = "Confirm", value = "confirm"}
			}

			ESX.OpenContext("right", elements2, function(menu2,element2)
				local data2 = {value = menu2.eles[2].inputValue}
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification(TranslateCap('quantity_invalid'))
				else
					ESX.CloseContext()
					TriggerServerEvent('esx_policejob:getStockItem', itemName, count)

					Wait(300)
					OpenGetStocksMenu()
				end
			end)
		end)
	end)
end

function OpenPutStocksMenu()
	ESX.TriggerServerCallback('esx_policejob:getPlayerInventory', function(inventory)
		local elements = {
			{unselectable = true, icon = "fas fa-box", title = TranslateCap('inventory')}
		}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				elements[#elements+1] = {
					icon = "fas fa-box",
					title = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				}
			end
		end

		ESX.OpenContext("right", elements, function(menu,element)
			local data = {current = element}
			local itemName = data.current.value

			local elements2 = {
				{unselectable = true, icon = "fas fa-box", title = element.title},
				{title = TranslateCap('quantity'), input = true, inputType = "number", inputMin = 1, inputMax = 150, inputPlaceholder = "Amount to withdraw.."},
				{icon = "fas fa-check-double", title = "Confirm", value = "confirm"}
			}

			ESX.OpenContext("right", elements2, function(menu2,element2)
				local data2 = {value = menu2.eles[2].inputValue}
				local count = tonumber(data2.value)

				if not count then
					ESX.ShowNotification(TranslateCap('quantity_invalid'))
				else
					ESX.CloseContext()
					TriggerServerEvent('esx_policejob:putStockItems', itemName, count)

					Wait(300)
					OpenPutStocksMenu()
				end
			end)
		end)
	end)
end

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	if job.name == 'police' then
		Wait(1000)
		TriggerServerEvent('esx_policejob:forceBlip')
	end
end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
	local specialContact = {
		name       = TranslateCap('phone_police'),
		number     = 'police',
		base64Icon = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6NDFGQTJDRkI0QUJCMTFFN0JBNkQ5OENBMUI4QUEzM0YiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NDFGQTJDRkM0QUJCMTFFN0JBNkQ5OENBMUI4QUEzM0YiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDo0MUZBMkNGOTRBQkIxMUU3QkE2RDk4Q0ExQjhBQTMzRiIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDo0MUZBMkNGQTRBQkIxMUU3QkE2RDk4Q0ExQjhBQTMzRiIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PoW66EYAAAjGSURBVHjapJcLcFTV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'
	}

	TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
end)

-- don't show dispatches if the player isn't in service
AddEventHandler('esx_phone:cancelMessage', function(dispatchNumber)
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' and ESX.PlayerData.job.name == dispatchNumber then
		-- if esx_service is enabled
		if Config.EnableESXService and not playerInService then
			CancelEvent()
		end
	end
end)

AddEventHandler('esx_policejob:hasEnteredMarker', function(station, part, partNum)
	if part == 'Cloakroom' then
		CurrentAction     = 'menu_cloakroom'
		CurrentActionMsg  = TranslateCap('open_cloackroom')
		CurrentActionData = {}
	elseif part == 'Armory' then
		CurrentAction     = 'menu_armory'
		CurrentActionMsg  = TranslateCap('open_armory')
		CurrentActionData = {station = station}
	elseif part == 'Vehicles' then
		CurrentAction     = 'menu_vehicle_spawner'
		CurrentActionMsg  = TranslateCap('garage_prompt')
		CurrentActionData = {station = station, part = part, partNum = partNum}
	elseif part == 'Helicopters' then
		CurrentAction     = 'Helicopters'
		CurrentActionMsg  = TranslateCap('helicopter_prompt')
		CurrentActionData = {station = station, part = part, partNum = partNum}
	elseif part == 'BossActions' then
		CurrentAction     = 'menu_boss_actions'
		CurrentActionMsg  = TranslateCap('open_bossmenu')
		CurrentActionData = {}
	end
end)

AddEventHandler('esx_policejob:hasExitedMarker', function(station, part, partNum)
	if not isInShopMenu then
		ESX.CloseContext()
	end

	CurrentAction = nil
end)

AddEventHandler('esx_policejob:hasEnteredEntityZone', function(entity)
	local playerPed = PlayerPedId()

	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' and IsPedOnFoot(playerPed) then
		CurrentAction     = 'remove_entity'
		CurrentActionMsg  = TranslateCap('remove_prop')
		CurrentActionData = {entity = entity}
	end

	if GetEntityModel(entity) == `p_ld_stinger_s` then
		local playerPed = PlayerPedId()
		local coords    = GetEntityCoords(playerPed)

		if IsPedInAnyVehicle(playerPed, false) then
			local vehicle = GetVehiclePedIsIn(playerPed)

			for i=0, 7, 1 do
				SetVehicleTyreBurst(vehicle, i, true, 1000)
			end
		end
	end
end)

AddEventHandler('esx_policejob:hasExitedEntityZone', function(entity)
	if CurrentAction == 'remove_entity' then
		CurrentAction = nil
	end
end)

RegisterNetEvent('esx_policejob:handcuff')
AddEventHandler('esx_policejob:handcuff', function()
	isHandcuffed = not isHandcuffed
	LocalPlayer.state:set("handcuffed", isHandcuffed, true)
	local playerPed = PlayerPedId()

	if isHandcuffed then
		RequestAnimDict('mp_arresting')
		while not HasAnimDictLoaded('mp_arresting') do
			Wait(100)
		end

		TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)
		RemoveAnimDict('mp_arresting')

		SetEnableHandcuffs(playerPed, true)
		DisablePlayerFiring(playerPed, true)
		SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true) -- unarm player
		SetPedCanPlayGestureAnims(playerPed, false)
		DisplayRadar(false)

		if Config.HandcuffDisableMovement then
			FreezeEntityPosition(playerPed, true)
		end

		if Config.EnableHandcuffTimer then
			if handcuffTimer.active then
				ESX.ClearTimeout(handcuffTimer.task)
			end

			StartHandcuffTimer()
		end
	else
		if Config.EnableHandcuffTimer and handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end

		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		DisplayRadar(true)

		if Config.HandcuffDisableMovement then
			FreezeEntityPosition(playerPed, false)
		end
	end
end)

RegisterNetEvent('esx_policejob:unrestrain')
AddEventHandler('esx_policejob:unrestrain', function()
	if isHandcuffed then
		local playerPed = PlayerPedId()
		isHandcuffed = false
		LocalPlayer.state:set("handcuffed", isHandcuffed, true)

		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(true)

		-- end timer
		if Config.EnableHandcuffTimer and handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end
	end
end)

RegisterNetEvent('esx_policejob:drag')
AddEventHandler('esx_policejob:drag', function(copId)
	if isHandcuffed then
		dragStatus.isDragged = not dragStatus.isDragged
		dragStatus.CopId = copId
	end
end)

CreateThread(function()
	local wasDragged

	while true do
		local Sleep = 1500

		if isHandcuffed and dragStatus.isDragged then
			Sleep = 50
			local targetPed = GetPlayerPed(GetPlayerFromServerId(dragStatus.CopId))

			if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
				if not wasDragged then
					AttachEntityToEntity(ESX.PlayerData.ped, targetPed, 11816, 0.30, 0.30, 0.0, 0.0, 0.0, 0.0, false, false, true, false, 2, true)
					wasDragged = true
				else
					Wait(1000)
				end
			else
				wasDragged = false
				dragStatus.isDragged = false
				DetachEntity(ESX.PlayerData.ped, true, false)
			end
		elseif wasDragged then
			wasDragged = false
			DetachEntity(ESX.PlayerData.ped, true, false)
		end
	Wait(Sleep)
	end
end)

RegisterNetEvent('esx_policejob:putInVehicle')
AddEventHandler('esx_policejob:putInVehicle', function()
	if isHandcuffed then
		local playerPed = PlayerPedId()
		local vehicle, distance = ESX.Game.GetClosestVehicle()

		if vehicle and distance < 5 then
			for i=1, GetVehicleMaxNumberOfPassengers(vehicle) - 1, 1 do
				if IsVehicleSeatFree(vehicle, i) then
					TaskWarpPedIntoVehicle(playerPed, vehicle, i)
					dragStatus.isDragged = false
					break
				end
			end
		end
	end
end)

RegisterNetEvent('esx_policejob:OutVehicle')
AddEventHandler('esx_policejob:OutVehicle', function()
	local GetVehiclePedIsIn = GetVehiclePedIsIn
	local IsPedSittingInAnyVehicle = IsPedSittingInAnyVehicle
	local TaskLeaveVehicle = TaskLeaveVehicle
	if IsPedSittingInAnyVehicle(ESX.PlayerData.ped) then
		local vehicle = GetVehiclePedIsIn(ESX.PlayerData.ped, false)
		TaskLeaveVehicle(ESX.PlayerData.ped, vehicle, 64)
	end
end)

-- Handcuff
CreateThread(function()
	local DisableControlAction = DisableControlAction
	local IsEntityPlayingAnim = IsEntityPlayingAnim
	while true do
		local Sleep = 1000

		if isHandcuffed then
			Sleep = 0

			if Config.HandcuffDisableLook then
				DisableControlAction(0, 1, true) -- Disable pan
				DisableControlAction(0, 2, true) -- Disable tilt
			end
			if Config.HandcuffDisableMovement then
				DisableControlAction(0, 32, true) -- W
				DisableControlAction(0, 34, true) -- A
				DisableControlAction(0, 31, true) -- S
				DisableControlAction(0, 30, true) -- D
			end

			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 21, true) -- Sprint
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?

			DisableControlAction(0, 288,  true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job

			DisableControlAction(0, 0, true) -- Disable changing view
			DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			DisableControlAction(2, 199, true) -- Disable pause screen

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle

			if IsEntityPlayingAnim(ESX.PlayerData.ped, 'mp_arresting', 'idle', 3) ~= 1 then
				ESX.Streaming.RequestAnimDict('mp_arresting', function()
					TaskPlayAnim(ESX.PlayerData.ped, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
					RemoveAnimDict('mp_arresting')
				end)
			end
		end
	Wait(Sleep)
	end
end)

-- Create blips
CreateThread(function()
	for k,v in pairs(Config.PoliceStations) do
		local blip = AddBlipForCoord(v.Blip.Coords)

		SetBlipSprite (blip, v.Blip.Sprite)
		SetBlipDisplay(blip, v.Blip.Display)
		SetBlipScale  (blip, v.Blip.Scale)
		SetBlipColour (blip, v.Blip.Colour)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(TranslateCap('map_blip'))
		EndTextCommandSetBlipName(blip)
	end
end)

-- Draw markers and more
CreateThread(function()
	while true do
		local Sleep = 1500
		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
			Sleep = 500
			local playerPed = PlayerPedId()
			local playerCoords = GetEntityCoords(playerPed)
			local isInMarker, hasExited = false, false
			local currentStation, currentPart, currentPartNum

			for k,v in pairs(Config.PoliceStations) do
				for i=1, #v.Cloakrooms, 1 do
					local distance = #(playerCoords - v.Cloakrooms[i])

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.Cloakrooms, v.Cloakrooms[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						Sleep = 0

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Cloakroom', i
						end
					end
				end

				for i=1, #v.Armories, 1 do
					local distance = #(playerCoords - v.Armories[i])

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.Armories, v.Armories[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						Sleep = 0

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Armory', i
						end
					end
				end

				for i=1, #v.Vehicles, 1 do
					local distance = #(playerCoords - v.Vehicles[i].Spawner)

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.Vehicles, v.Vehicles[i].Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						Sleep = 0

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Vehicles', i
						end
					end
				end

				for i=1, #v.Helicopters, 1 do
					local distance =  #(playerCoords - v.Helicopters[i].Spawner)

					if distance < Config.DrawDistance then
						DrawMarker(Config.MarkerType.Helicopters, v.Helicopters[i].Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
						Sleep = 0

						if distance < Config.MarkerSize.x then
							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Helicopters', i
						end
					end
				end

				if Config.EnablePlayerManagement and ESX.PlayerData.job.grade_name == 'boss' then
					for i=1, #v.BossActions, 1 do
						local distance = #(playerCoords - v.BossActions[i])

						if distance < Config.DrawDistance then
							DrawMarker(Config.MarkerType.BossActions, v.BossActions[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
							Sleep = 0

							if distance < Config.MarkerSize.x then
								isInMarker, currentStation, currentPart, currentPartNum = true, k, 'BossActions', i
							end
						end
					end
				end
			end

			if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then
				if
					(LastStation and LastPart and LastPartNum) and
					(LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
				then
					TriggerEvent('esx_policejob:hasExitedMarker', LastStation, LastPart, LastPartNum)
					hasExited = true
				end

				HasAlreadyEnteredMarker = true
				LastStation             = currentStation
				LastPart                = currentPart
				LastPartNum             = currentPartNum

				TriggerEvent('esx_policejob:hasEnteredMarker', currentStation, currentPart, currentPartNum)
			end

			if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_policejob:hasExitedMarker', LastStation, LastPart, LastPartNum)
			end
		end
	Wait(Sleep)
	end
end)

-- Enter / Exit entity zone events
CreateThread(function()
	local trackedEntities = {
		`prop_roadcone02a`,
		`prop_barrier_work05`,
		`p_ld_stinger_s`,
		`prop_boxpile_07d`,
		`hei_prop_cash_crate_half_full`
	}

	while true do
		local Sleep = 1500

			local GetEntityCoords = GetEntityCoords
			local GetClosestObjectOfType = GetClosestObjectOfType
			local DoesEntityExist = DoesEntityExist
			local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
	
			local closestDistance = -1
			local closestEntity   = nil

			for i=1, #trackedEntities, 1 do
				local object = GetClosestObjectOfType(playerCoords, 3.0, trackedEntities[i], false, false, false)

				if DoesEntityExist(object) then
					Sleep = 500
					local objCoords = GetEntityCoords(object)
					local distance = #(playerCoords - objCoords)

					if closestDistance == -1 or closestDistance > distance then
						closestDistance = distance
						closestEntity   = object
					end
				end
			end

			if closestDistance ~= -1 and closestDistance <= 3.0 then
				if LastEntity ~= closestEntity then
					TriggerEvent('esx_policejob:hasEnteredEntityZone', closestEntity)
					LastEntity = closestEntity
				end
			else
				if LastEntity then
					TriggerEvent('esx_policejob:hasExitedEntityZone', LastEntity)
					LastEntity = nil
				end
			end
		Wait(Sleep)
	end
end)

ESX.RegisterInput("police:interact", "(ESX PoliceJob) Interact", "keyboard", "E", function()
	if not CurrentAction then 
		return 
	end

	if not ESX.PlayerData.job or (ESX.PlayerData.job and not ESX.PlayerData.job.name == 'police') then
		return
	end
	if CurrentAction == 'menu_cloakroom' then
		OpenCloakroomMenu()
	elseif CurrentAction == 'menu_armory' then
		if not Config.EnableESXService then
			OpenArmoryMenu(CurrentActionData.station)
		elseif playerInService then
			OpenArmoryMenu(CurrentActionData.station)
		else
			ESX.ShowNotification(TranslateCap('service_not'))
		end
	elseif CurrentAction == 'menu_vehicle_spawner' then
		if not Config.EnableESXService then
			OpenVehicleSpawnerMenu('car', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
		elseif playerInService then
			OpenVehicleSpawnerMenu('car', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
		else
			ESX.ShowNotification(TranslateCap('service_not'))
		end
	elseif CurrentAction == 'Helicopters' then
		if not Config.EnableESXService then
			OpenVehicleSpawnerMenu('helicopter', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
		elseif playerInService then
			OpenVehicleSpawnerMenu('helicopter', CurrentActionData.station, CurrentActionData.part, CurrentActionData.partNum)
		else
			ESX.ShowNotification(TranslateCap('service_not'))
		end
	elseif CurrentAction == 'delete_vehicle' then
		ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
	elseif CurrentAction == 'menu_boss_actions' then
		ESX.CloseContext()
		TriggerEvent('esx_society:openBossMenu', 'police', function(data, menu)
			menu.close()

			CurrentAction     = 'menu_boss_actions'
			CurrentActionMsg  = TranslateCap('open_bossmenu')
			CurrentActionData = {}
		end, { wash = false }) -- disable washing money
	elseif CurrentAction == 'remove_entity' then
		DeleteEntity(CurrentActionData.entity)
	end

	CurrentAction = nil
end)

CreateThread(function()
	while true do
		local Sleep = 1000

		if CurrentAction then
			Sleep = 0
			ESX.ShowHelpNotification(CurrentActionMsg)
		end
	Wait(Sleep)
	end
end)

-- Create blip for colleagues
function createBlip(id)
	local ped = GetPlayerPed(id)
	local blip = GetBlipFromEntity(ped)

	if not DoesBlipExist(blip) then -- Add blip and create head display on player
		blip = AddBlipForEntity(ped)
		SetBlipSprite(blip, 1)
		ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
		SetBlipRotation(blip, math.ceil(GetEntityHeading(ped))) -- update rotation
		SetBlipNameToPlayerName(blip, id) -- update blip name
		SetBlipScale(blip, 0.85) -- set scale
		SetBlipAsShortRange(blip, true)

		table.insert(blipsCops, blip) -- add blip to array so we can remove it later
	end
end

RegisterNetEvent('esx_policejob:updateBlip')
AddEventHandler('esx_policejob:updateBlip', function()

	-- Refresh all blips
	for k, existingBlip in pairs(blipsCops) do
		RemoveBlip(existingBlip)
	end

	-- Clean the blip table
	blipsCops = {}

	-- Enable blip?
	if Config.EnableESXService and not playerInService then
		return
	end

	if not Config.EnableJobBlip then
		return
	end

	-- Is the player a cop? In that case show all the blips for other cops
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
		ESX.TriggerServerCallback('esx_society:getOnlinePlayers', function(players)
			for i=1, #players, 1 do
				if players[i].job.name == 'police' then
					local id = GetPlayerFromServerId(players[i].source)
					if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= PlayerPedId() then
						createBlip(id)
					end
				end
			end
		end)
	end

end)

AddEventHandler('esx:onPlayerSpawn', function(spawn)
	isDead = false
	TriggerEvent('esx_policejob:unrestrain')

	if not hasAlreadyJoined then
		TriggerServerEvent('esx_policejob:spawned')
	end
	hasAlreadyJoined = true
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('esx_policejob:unrestrain')
		TriggerEvent('esx_phone:removeSpecialContact', 'police')

		if Config.EnableESXService then
			TriggerServerEvent('esx_service:disableService', 'police')
		end

		if Config.EnableHandcuffTimer and handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end
	end
end)

-- handcuff timer, unrestrain the player after an certain amount of time
function StartHandcuffTimer()
	if Config.EnableHandcuffTimer and handcuffTimer.active then
		ESX.ClearTimeout(handcuffTimer.task)
	end

	handcuffTimer.active = true

	handcuffTimer.task = ESX.SetTimeout(Config.HandcuffTimer, function()
		ESX.ShowNotification(TranslateCap('unrestrained_timer'))
		TriggerEvent('esx_policejob:unrestrain')
		handcuffTimer.active = false
	end)
end

if ESX.PlayerLoaded and ESX.PlayerData.job == 'police' then
	SetTimeout(1000, function()
		TriggerServerEvent('esx_policejob:forceBlip')
	end)
end


--- Handcuff Animations
--- Credits: GaluzaCZ

-- Uncuff
RegisterNetEvent('esx_policejob:handcuffAnim:getUncuffed')
AddEventHandler('esx_policejob:handcuffAnim:getUncuffed', function(cufferId)
	LocalPlayer.state:set("handcuffAnim", true, true)
	local cufferPed = GetPlayerPed(GetPlayerFromServerId(cufferId))

	ESX.Streaming.RequestAnimDict('mp_arresting', function()
		AttachEntityToEntity(ESX.PlayerData.ped, cufferPed, 11816, 0.0, 0.60, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, false)

		ClearPedTasksImmediately(ESX.PlayerData.ped)
		TaskPlayAnim(ESX.PlayerData.ped, 'mp_arresting', 'b_uncuff', 8.0, 8.0,5500, 2, 0, 0, 0, 0)
		RemoveAnimDict('mp_arresting')
		Citizen.Wait(5500)

		DetachEntity(ESX.PlayerData.ped, true, false)

		LocalPlayer.state:set("handcuffAnim", false, true)
	end)
end)

RegisterNetEvent('esx_policejob:handcuffAnim:doUncuffing')
AddEventHandler('esx_policejob:handcuffAnim:doUncuffing', function()
	LocalPlayer.state:set("handcuffAnim", true, true)

	ESX.Streaming.RequestAnimDict('mp_arresting', function()
		ClearPedTasksImmediately(ESX.PlayerData.ped)
		TaskPlayAnim(ESX.PlayerData.ped, 'mp_arresting', 'a_uncuff', 8.0, 8.0,5500, 2, 0, 0, 0, 0)
		RemoveAnimDict('mp_arresting')
		Citizen.Wait(5500)

		LocalPlayer.state:set("handcuffAnim", false, true)
	end)
end)


-- Cuff
RegisterNetEvent('esx_policejob:handcuffAnim:getCuffed')
AddEventHandler('esx_policejob:handcuffAnim:getCuffed', function(cufferId)
	LocalPlayer.state:set("handcuffAnim", true, true)
	local cufferPed = GetPlayerPed(GetPlayerFromServerId(cufferId))

	ESX.Streaming.RequestAnimDict('mp_arrest_paired', function()
		AttachEntityToEntity(ESX.PlayerData.ped, cufferPed, 11816, 0.0, 0.65, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, false)

		ClearPedTasksImmediately(ESX.PlayerData.ped)
		TaskPlayAnim(ESX.PlayerData.ped, 'mp_arrest_paired', 'crook_p2_back_left', 8.0, -8.0, 5500, 33, 0, false, false, false)
		RemoveAnimDict('mp_arrest_paired')
		Citizen.Wait(5500)

		DetachEntity(ESX.PlayerData.ped, true, false)

		LocalPlayer.state:set("handcuffAnim", false, true)
	end)
end)

RegisterNetEvent('esx_policejob:handcuffAnim:doCuffing')
AddEventHandler('esx_policejob:handcuffAnim:doCuffing', function()
	LocalPlayer.state:set("handcuffAnim", true, true)

	ESX.Streaming.RequestAnimDict('mp_arrest_paired', function()
		ClearPedTasksImmediately(ESX.PlayerData.ped)
		TaskPlayAnim(ESX.PlayerData.ped, 'mp_arrest_paired', 'cop_p2_back_left', 8.0, -8.0, 5500, 33, 0, false, false, false)
		RemoveAnimDict('mp_arrest_paired')
		Citizen.Wait(5500)

		LocalPlayer.state:set("handcuffAnim", false, true)
	end)
end)