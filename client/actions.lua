function OpenIdentityCardMenu(player)
	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)
		local elements = {
			{icon = "fas fa-user", title = TranslateCap('name', data.name)},
			{icon = "fas fa-user", title = TranslateCap('job', ('%s - %s'):format(data.job, data.grade))}
		}

		if Config.EnableESXIdentity then
			elements[#elements+1] = {icon = "fas fa-user", title = TranslateCap('sex', TranslateCap(data.sex))}
			elements[#elements+1] = {icon = "fas fa-user", title = TranslateCap('height', data.height)}
		end

		if Config.EnableESXOptionalneeds and data.drunk then
			elements[#elements+1] = {title = TranslateCap('bac', data.drunk)}
		end

		if data.licenses then
			elements[#elements+1] = {title = TranslateCap('license_label')}

			for i=1, #data.licenses, 1 do
				elements[#elements+1] = {title = data.licenses[i].label}
			end
		end

		ESX.OpenContext("right", elements, nil, function(menu)
			OpenPoliceActionsMenu()
		end)
	end, GetPlayerServerId(player))
end

function OpenBodySearchMenu(player)
	if Config.OxInventory then
		ESX.CloseContext()
		exports.ox_inventory:openInventory('player', GetPlayerServerId(player))
		return
	end

	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)
		local elements = {
			{unselectable = true, icon = "fas fa-user", title = TranslateCap('search')}
		}

		for i=1, #data.accounts, 1 do
			if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
				elements[#elements+1] = {
					icon = "fas fa-money",
					title    = TranslateCap('confiscate_dirty', ESX.Math.Round(data.accounts[i].money)),
					value    = 'black_money',
					itemType = 'item_account',
					amount   = data.accounts[i].money
				}
				break
			end
		end

		table.insert(elements, {label = TranslateCap('guns_label')})

		for i=1, #data.weapons, 1 do
			elements[#elements+1] = {
				icon = "fas fa-gun",
				title    = TranslateCap('confiscate_weapon', ESX.GetWeaponLabel(data.weapons[i].name), data.weapons[i].ammo),
				value    = data.weapons[i].name,
				itemType = 'item_weapon',
				amount   = data.weapons[i].ammo
			}
		end

		elements[#elements+1] = {title = TranslateCap('inventory_label')}

		for i=1, #data.inventory, 1 do
			if data.inventory[i].count > 0 then
				elements[#elements+1] = {
					icon = "fas fa-box",
					title    = TranslateCap('confiscate_inv', data.inventory[i].count, data.inventory[i].label),
					value    = data.inventory[i].name,
					itemType = 'item_standard',
					amount   = data.inventory[i].count
				}
			end
		end

		ESX.OpenContext("right", elements, function(menu,element)
			local data = {current = element}
			if data.current.value then
				TriggerServerEvent('esx_policejob:confiscatePlayerItem', GetPlayerServerId(player), data.current.itemType, data.current.value, data.current.amount)
				OpenBodySearchMenu(player)
			end
		end)
	end, GetPlayerServerId(player))
end

function OpenFineMenu(player)
	local elements = {
		{unselectable = true, icon = "fas fa-scroll", title = TranslateCap('fine')},
		{icon = "fas fa-scroll", title = TranslateCap('traffic_offense'), value = 0},
		{icon = "fas fa-scroll", title = TranslateCap('minor_offense'),   value = 1},
		{icon = "fas fa-scroll", title = TranslateCap('average_offense'), value = 2},
		{icon = "fas fa-scroll", title = TranslateCap('major_offense'),   value = 3}
	}

	ESX.OpenContext("right", elements, function(menu,element)
		local data = {current = element}
		OpenFineCategoryMenu(player, data.current.value)
	end)
end

function OpenFineCategoryMenu(player, category)
	ESX.TriggerServerCallback('esx_policejob:getFineList', function(fines)
		local elements = {
			{unselectable = true, icon = "fas fa-scroll", title = TranslateCap('fine')}
		}

		for k,fine in ipairs(fines) do
			elements[#elements+1] = {
				icon = "fas fa-scroll",
				title     = ('%s <span style="color:green;">%s</span>'):format(fine.label, TranslateCap('armory_item', ESX.Math.GroupDigits(fine.amount))),
				value     = fine.id,
				amount    = fine.amount,
				fineLabel = fine.label
			}
		end

		ESX.OpenContext("right", elements, function(menu,element)
			local data = {current = element}
			if Config.EnablePlayerManagement then
				TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_police', TranslateCap('fine_total', data.current.fineLabel), data.current.amount)
			else
				TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), '', TranslateCap('fine_total', data.current.fineLabel), data.current.amount)
			end

			ESX.CloseContext()
		end)
	end, category)
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

function OpenVehicleInfosMenu(vehicle)
	ESX.TriggerServerCallback('esx_policejob:getVehicleInfos', function(retrivedInfo)
		local elements = {
			{unselectable = true, icon = "fas fa-car", title = TranslateCap('vehicle_info')},
			{icon = "fas fa-car", title = TranslateCap('plate', retrivedInfo.plate)}
		}

		if not retrivedInfo.owner then
			elements[#elements+1] = {unselectable = true, icon = "fas fa-user", title = TranslateCap('owner_unknown')}
		else
			elements[#elements+1] = {unselectable = true, icon = "fas fa-user", title = TranslateCap('owner', retrivedInfo.owner)}
		end

		ESX.OpenContext("right", elements, nil, nil)
	end, ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)))
end

function HijackVehicle(vehicle)
	local playerPed = PlayerPedId()

	TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
	Wait(20000)
	ClearPedTasksImmediately(playerPed)

	SetVehicleDoorsLocked(vehicle, 1)
	SetVehicleDoorsLockedForAllPlayers(vehicle, false)
	ESX.ShowNotification(TranslateCap('vehicle_unlocked'))
end

local currentTask = {}
function ImpoundNearVehicle(vehicle)
	if currentTask.busy then return end

	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	ESX.ShowHelpNotification(TranslateCap('impound_prompt'))
	TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)

	currentTask.busy = true
	currentTask.task = ESX.SetTimeout(10000, function()
		ClearPedTasks(playerPed)
		ImpoundVehicle(vehicle)
		Wait(100)
	end)

	CreateThread(function()
		while currentTask.busy do
			Wait(1000)

			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71)
			if not DoesEntityExist(vehicle) and currentTask.busy then
				ESX.ShowNotification(TranslateCap('impound_canceled_moved'))
				ESX.ClearTimeout(currentTask.task)
				ClearPedTasks(playerPed)
				currentTask.busy = false
				break
			end
		end
	end)
end

-- TODO
--   - return to garage if owned
--   - message owner that his vehicle has been impounded
function ImpoundVehicle(vehicle)
	--local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
	ESX.Game.DeleteVehicle(vehicle)
	ESX.ShowNotification(TranslateCap('impound_successful'))
	currentTask.busy = false
end

function TakePlayerFromVehicle(vehicle)
	for i = GetVehicleMaxNumberOfPassengers(vehicle) - 1, 1, -1 do
		if not IsVehicleSeatFree(vehicle, i) then
			local targetPed = GetPedInVehicleSeat(vehicle, i)
			local target = NetworkGetPlayerIndexFromPed(targetPed)
			if target ~= -1 then
				TriggerServerEvent("esx_policejob:OutVehicle", GetPlayerServerId(target))
				break
			end
		end
	end
end

function LookupVehicle()
	local elements = {
		{unselectable = true, icon = "fas fa-car", title = TranslateCap('search_database')},
		{title = "Enter Plate", input = true, inputType = "text", inputPlaceholder = "ABC 123"},
		{icon = "fas fa-check-double", title = "Lookup Plate", value = "lookup"}
	}

	ESX.OpenContext("right", elements, function(menu,element)
		local data = {value = menu.eles[2].inputValue}
		local length = string.len(data.value)
		if not data.value or length < 2 or length > 8 then
			ESX.ShowNotification(TranslateCap('search_database_error_invalid'))
		else
			ESX.TriggerServerCallback('esx_policejob:getVehicleInfos', function(retrivedInfo)
				local elements = {
					{unselectable = true, icon = "fas fa-car", title = element.title},
					{unselectable = true, icon = "fas fa-car", title = TranslateCap('plate', retrivedInfo.plate)}			
				}

				if not retrivedInfo.owner then
					elements[#elements+1] = {unselectable = true, icon = "fas fa-user", title = TranslateCap('owner_unknown')}
				else
					elements[#elements+1] = {unselectable = true, icon = "fas fa-user", title = TranslateCap('owner', retrivedInfo.owner)}
				end

				ESX.OpenContext("right", elements, nil, function(menu)
					OpenPoliceActionsMenu()
				end)
			end, data.value)
		end
	end)
end

local Actions = {
    citizen_interaction = {
        {
            value = 'identity_card',
            title = TranslateCap('id_card'),
            func = OpenIdentityCardMenu
        },
        {
            value = 'search',
            title = TranslateCap('search'),
            func = OpenBodySearchMenu,
			canInteract = function(entity)
				return Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.handcuffed
			end
        },
        {
            value = 'handcuff',
            title = TranslateCap('handcuff'),
            event = 'esx_policejob:handcuffAnim'
        },
        {
            value = 'drag',
            title = TranslateCap('drag'),
            event = 'esx_policejob:drag',
			canInteract = function(entity)
				return Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.handcuffed
			end
        },
        {
            value = 'put_in_vehicle',
            title = TranslateCap('put_in_vehicle'),
            event = 'esx_policejob:putInVehicle',
			canInteract = function(entity)
				return Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))).state.handcuffed
			end
        },
        {
            value = 'out_the_vehicle',
            title = TranslateCap('out_the_vehicle'),
            event = 'esx_policejob:OutVehicle',
			disableTarget = true
        },
        {
            value = 'fine',
            title = TranslateCap('fine'),
            func = OpenFineMenu
        },
        {
            value = 'unpaid_bills',
            title = TranslateCap('unpaid_bills'),
            func = OpenUnpaidBillsMenu
        },
    },
	vehicle_interaction = {
		{
			value = 'vehicle_infos',
            title = TranslateCap('vehicle_info'),
            func = OpenVehicleInfosMenu
		},
		{
			value = 'hijack_vehicle',
            title = TranslateCap('pick_lock'),
            func = HijackVehicle
		},
		{
			value = 'impound',
            title = TranslateCap('impound'),
            func = ImpoundNearVehicle
		},
		{
			value = 'vehicle_player_out',
			title = TranslateCap('out_the_vehicle'),
			func = TakePlayerFromVehicle,
			disableMenu = true,
			canInteract = function(entity)
				for i = GetVehicleMaxNumberOfPassengers(entity) - 1, 1, -1 do
					if not IsVehicleSeatFree(entity, i) then
						return true
					end
				end
				return false
			end
		},
	},
	object_spawner = {
		{title = TranslateCap('cone'), model = 'prop_roadcone02a'},
		{title = TranslateCap('barrier'), model = 'prop_barrier_work05'},
		{title = TranslateCap('spikestrips'), model = 'p_ld_stinger_s'},
		{title = TranslateCap('box'), model = 'prop_boxpile_07d'},
		{title = TranslateCap('cash'), model = 'hei_prop_cash_crate_half_full'},
	}
}

if Config.EnableLicenses then
    Actions.citizen_interaction[#Actions.citizen_interaction+1] = {
        value = 'license',
        title = TranslateCap('license_check'),
        func = ShowPlayerLicense
    }
end

function OpenPoliceActionsMenu()
	local elements = {
		{unselectable = true, icon = "fas fa-triangle-exclamation", title = "Police"},
		{icon = "fas fa-user", title = TranslateCap('citizen_interaction'), value = 'citizen_interaction'},
		{icon = "fas fa-car", title = TranslateCap('vehicle_interaction'), value = 'vehicle_interaction'}
	}

	if Config.EnableObjectSpawner then
		elements[#elements+1] = {icon = "fas fa-box-open", title = TranslateCap('object_spawner'), value = 'object_spawner'}
	end

	ESX.OpenContext("right", elements, function(menu,element)
		if element.value == 'citizen_interaction' then
			local elements2 = {
                {unselectable = true, icon = "fas fa-triangle-exclamation", title = element.title}
            }

            for i = 1, #Actions.citizen_interaction do
                local action = Actions.citizen_interaction[i]
				if not action.disableMenu then
					elements2[#elements2+1] = {icon = 'fas fa-eye', title = action.title, i = i}
				end
            end

			ESX.OpenContext("right", elements2, function(menu2, element2)
                local action = Actions.citizen_interaction[element2.i]
				local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
				if closestPlayer == -1 or closestDistance > 3.0 then return ESX.ShowNotification(TranslateCap('no_players_nearby')) end

                if action.func then action.func(closestPlayer) end
                if action.event then TriggerServerEvent(action.event, GetPlayerServerId(closestPlayer)) end
			end, function()
				OpenPoliceActionsMenu()
			end)
		elseif element.value == 'vehicle_interaction' then
			local elements2  = {
				{unselectable = true, icon = "fas fa-triangle-exclamation", title = element.title}
			}
			local vehicle = ESX.Game.GetVehicleInDirection()

			if DoesEntityExist(vehicle) then
				for i = 1, #Actions.vehicle_interaction do
					local action = Actions.vehicle_interaction[i]
					if not action.disableMenu then
						elements2[#elements2+1] = {icon = 'fas fa-car', title = action.title, action = action}
					end
				end
			end

			elements2[#elements2+1] = {
				icon = 'fas fa-car',
				value = 'search_database',
				title = TranslateCap('search_database'),
				action = {
					func = LookupVehicle
				}
			}

			ESX.OpenContext("right", elements2, function(menu2,element2)
				vehicle = ESX.Game.GetVehicleInDirection()
				if not vehicle then return TranslateCap('no_vehicles_nearby') end

				if element2.action.func then element2.action.func(vehicle) end
                if element2.action.event then TriggerServerEvent(element2.action.event, NetworkGetNetworkIdFromEntity(vehicle)) end
			end, function()
				OpenPoliceActionsMenu()
			end)
		elseif element.value == "object_spawner" then
			local elements2 = {
				{unselectable = true, icon = "fas fa-triangle-exclamation", title = element.title}
			}

			for i = 1, #Actions.object_spawner do
				local action = Actions.object_spawner[i]
				elements2[#elements2+1] = {icon = 'fas fa-box-open', title = action.title, model = action.model}
			end

			ESX.OpenContext("right", elements2, function(menu2,element2)
				local playerPed = PlayerPedId()
				local coords, forward = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
				local objectCoords = (coords + forward * 1.0)

				ESX.Game.SpawnObject(element2.model, objectCoords, function(obj)
					SetEntityHeading(obj, GetEntityHeading(playerPed))
					PlaceObjectOnGroundProperly(obj)
				end)
			end, function()
				OpenPoliceActionsMenu()
			end)
		end
	end)
end

ESX.RegisterInput("police:quickactions", "(ESX PoliceJob) Quick Actions", "keyboard", "F6", function()
	if not ESX.PlayerData.job or (ESX.PlayerData.job.name ~= 'police') or isDead then
		return
	end

	if not Config.EnableESXService then
		OpenPoliceActionsMenu()
	elseif playerInService then
		OpenPoliceActionsMenu()
	else
		ESX.ShowNotification(TranslateCap('service_not'))
	end
end)

if Config.EnableTarget and (GetResourceState('ox_target') == 'started') then
	local options = {}

	for i = 1, #Actions.citizen_interaction do
		local action = Actions.citizen_interaction[i]
		if not action.disableTarget then
			options[#options+1] = {
				label = action.title,
				icon = action.icon or 'fas fa-eye',
				distance = 3.0,
				groups = 'police',
				canInteract = action.canInteract,
				onSelect = function(data)
					local player = NetworkGetPlayerIndexFromPed(data.entity)
					if action.func then action.func(player) end
        	        if action.event then TriggerServerEvent(action.event, GetPlayerServerId(player)) end
				end
			}
		end
	end

	exports.ox_target:addGlobalPlayer(options)

	local options2 = {}

	for i = 1, #Actions.vehicle_interaction do
		local action = Actions.vehicle_interaction[i]
		if not action.disableTarget then
			options2[#options2+1] = {
				label = action.title,
				icon = action.icon or 'fas fa-car',
				distance = 3.0,
				groups = 'police',
				canInteract = action.canInteract,
				onSelect = function(data)
					if action.func then action.func(data.entity) end
					if action.event then TriggerServerEvent(action.event, GetPlayerServerId(data.entity)) end
				end
			}
		end
	end

	exports.ox_target:addGlobalVehicle(options2)
end