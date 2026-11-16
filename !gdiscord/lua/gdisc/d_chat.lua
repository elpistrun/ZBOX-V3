require("gwsockets")
util.AddNetworkString("GDiscord_receive_message")

local netStart = net.Start
local netBroadcast = net.Broadcast
local netWriteString = net.WriteString
local JSONToTable = util.JSONToTable

local CONSOLE_ROLE_ID = "1429725095181418527"

GDiscord.setup_connection = function()
	
    GDiscord.wsock = GWSockets.createWebSocket(GDiscord.config['discord_gateway_link'])

    function GDiscord.wsock:onMessage(data)
		local recv = JSONToTable(data)
        if recv["op"] == 10 then 

			GDiscord.other['hb_interval'] = recv["d"]["heartbeat_interval"] / 10000
			timer.Simple(GDiscord.other['hb_interval'], function ()
				GDiscord.wsock:write(GDiscord.payloads['auth'])
				timer.Create("DS gateway heartbeat", GDiscord.other['hb_interval'], 0, function()
					GDiscord.wsock:write(GDiscord.payloads['heartbeat'])
				end)
			end)
	
		elseif recv['op'] == 0 and recv['t'] == "MESSAGE_CREATE" and recv['d']['channel_id'] == GDiscord.config['channel_id'] and not recv['d']['author']['bot'] then
			
			local message_content = recv['d']['content']
			local author_id = recv['d']['author']['id']
			local member_roles = recv['d']['member'] and recv['d']['member']['roles'] or {}
			
			-- Проверяем, есть ли у пользователя роль консоли
			local has_console_role = false
			for _, role_id in ipairs(member_roles) do
				if role_id == CONSOLE_ROLE_ID then
					has_console_role = true
					break
				end
			end
			
			local status_commands = {"!status", "!s", "!stat", "!статус", "!с", "!стат", "!С", "!C", "!c", "!S", "!Status", "!Статус", "!Стат", "!cnfnec", "!cnfn"}
			local is_status_command = false
			for _, cmd in ipairs(status_commands) do
				if message_content == cmd then
					is_status_command = true
					break
				end
			end
			
			if is_status_command then

				local player_count = #player.GetAll()
				local max_players = 38
				local map_name = game.GetMap()
				local server_ip = "185.97.255.43:22647"
				

				local embed_color = 0x2ecc2e  
				if player_count == 0 then
					embed_color = 0x2c3e50  
				end
				
local function getPlayerRole(ply)
    local userGroup = ply:GetUserGroup()  
    
    if userGroup == "superadmin" then
        return { prefix = "👑 [SA] ", rank = 1 }
    elseif userGroup == "Event-admin" then
        return { prefix = "🎬 [EA] ", rank = 2 }
    elseif userGroup == "admin" then
        return { prefix = "🔨 [A] ", rank = 3 }
    elseif userGroup == "dadmin" then
        return { prefix = "⭐ [DA] ", rank = 4 }
    elseif userGroup == "moder" then
        return { prefix = "🛡️ [M] ", rank = 5 }
    elseif userGroup == "stajer" then
        return { prefix = "📖 [S] ", rank = 6 }
    end
    
    return nil 
end
				

				local players = player.GetAll()
				local sorted_players = {}
				local admins = {}
				local regulars = {}
				
				for _, ply in ipairs(players) do
					local role = getPlayerRole(ply)
					if role then
						table.insert(admins, {ply = ply, role = role})
					else
						table.insert(regulars, ply)
					end
				end
				

				table.sort(admins, function(a, b) return a.role.rank < b.role.rank end)
				

				for _, adm in ipairs(admins) do
					table.insert(sorted_players, adm)
				end
				for _, ply in ipairs(regulars) do
					table.insert(sorted_players, ply)
				end
				
				local players_list = ""
				if #players > 0 then
					for _, item in ipairs(sorted_players) do
						local ply, role
						if item.ply then
							ply = item.ply
							role = item.role
						else
							ply = item
							role = nil
						end
						
						local steamid = ply:SteamID()
						local name = ply:Nick()
						
						if role then

							players_list = players_list .. "• " .. role.prefix .. " **" .. name .. "** — `" .. steamid .. "`\n"
						else
							players_list = players_list .. "• **" .. name .. "** — `" .. steamid .. "`\n"
						end
					end
				else
					players_list = "Нет игроков на сервере."
				end
				
				local embed = {
					["title"] = "🇿 |-BOX V3 | Реалистичный Сандбокс",
					["color"] = embed_color,
					["fields"] = {
						{
							["name"] = "👥 Количество игроков",
							["value"] = player_count .. " / " .. max_players,
							["inline"] = true
						},
						{
							["name"] = "🗺️ Нынешняя карта",
							["value"] = map_name,
							["inline"] = true
						},
						{
							["name"] = "📌 IP-адрес",
							["value"] = server_ip,
							["inline"] = false
						},
						{
							["name"] = "👶 Игроки",
							["value"] = players_list,
							["inline"] = false
						}
					},
					["footer"] = {
						["text"] = "Статус сервера • " .. os.date("%H:%M:%S - %d.%m.%Y")
					}
				}
				
				if GDiscord.sendToDS then
					local params = {
						['allowed_mentions'] = { ['parse'] = {} },
						['username'] = "Server Status",
						['embeds'] = { embed }
					}
					GDiscord.sendToDS(params)
				end
				return
			end
			
if has_console_role and string.sub(message_content, 1, 6) == "!exec " then
    local full_command = string.sub(message_content, 7)
    if full_command and full_command ~= "" then

        local parts = {}
        for part in string.gmatch(full_command, "%S+") do
            table.insert(parts, part)
        end
        
        if #parts > 0 then
            local cmd = table.remove(parts, 1) 
            local args = parts                   
            

            local success, err = pcall(function()
                RunConsoleCommand(cmd, unpack(args))
            end)
            
            if success then
                if GDiscord.sendToDS then
                    local params = {
                        ['allowed_mentions'] = { ['parse'] = {} },
                        ['username'] = "Console Executor",
                        ['content'] = "✅ Команда выполнена: `" .. full_command .. "`"
                    }
                    GDiscord.sendToDS(params)
                end
            else
                if GDiscord.sendToDS then
                    local params = {
                        ['allowed_mentions'] = { ['parse'] = {} },
                        ['username'] = "Console Executor",
                        ['content'] = "❌ Ошибка: `" .. tostring(err) .. "`"
                    }
                    GDiscord.sendToDS(params)
                end
            end
        end
    end
    return
end
			
			if string.sub(message_content, 1, 6) == "!exec " and not has_console_role then
				if GDiscord.sendToDS then
					local params = {
						['allowed_mentions'] = { ['parse'] = {} },
						['username'] = "Console Executor",
						['content'] = "❌ У вас нет прав для выполнения этой команды."
					}
					GDiscord.sendToDS(params)
				end
				return
			end

			netStart("GDiscord_receive_message")
				netWriteString(recv["d"]["author"]["username"])
				netWriteString(message_content)
			netBroadcast()

		end
    end

    function GDiscord.wsock:onError(txt)
		print("GDiscord disconnected. Error: ", txt)
		GDiscord.is_connected = false
		timer.Remove("DS gateway heartbeat")
		GDiscord.wsock:close()
	end

	function GDiscord.wsock:onConnected()
		print("GDiscord connected!")
		GDiscord.is_connected = true
	end

	function GDiscord.wsock:onDisconnected()
		print("GDiscord disconnected.")
		GDiscord.is_connected = false
		timer.Remove("DS gateway heartbeat")
		GDiscord.wsock:close()
	end

	GDiscord.wsock:open()
end

local function checkWSocket()
    if not GDiscord.is_connected then
        GDiscordInit()
    end
end

function GDiscordInit()
	timer.Remove("CheckGDiscordConnection")

	if GDiscord.wsock then 
		GDiscord.wsock:close()
	else 
		GDiscord.wsock = nil 
	end

	GDiscord.payloads = {}

	GDiscord.other = { 
		['hb_interval'] = nil, 
		['session_id'] = nil, 
		['seq'] = 0 
	}

	GDiscord.payloads['auth'] = string.format([[
		{
			"op": 2,
			"d": {
				"token": "%s",
				"properties": {
					"$os": "windows",
					"$browser": "chrome",
					"$device": "pc"
				}
			}
		}
	]], GDiscord.config['bot_token'])

	GDiscord.payloads['heartbeat'] = [[
		{
			"op": 1,
			"d": "null"
		}
	]]

	GDiscord.payloads['resume'] = string.format([[
		{
			"op": 6,
			"d": {
			"token": "%s",
			"session_id": "%s",
			"seq": %d
			}
		}
	]], GDiscord.config['bot_token'], GDiscord.other['session_id'], GDiscord.other['seq'])

    timer.Create("CheckGDiscordConnection", 5, 0, function() checkWSocket() end)
	GDiscord.setup_connection()
	hook.Remove("InitPostEntity", "InitGDiscord")
end

hook.Add("InitPostEntity", "InitGDiscord", GDiscordInit)