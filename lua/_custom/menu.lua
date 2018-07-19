bkin_bl__menu = bkin_bl__menu or class()
bkin_bl__menu.menu_id = "bkin_bl__menu"
bkin_bl__menu._data_path = BigLobbyGlobals.SavePath .. "bkin_bl__settings.json"
bkin_bl__menu._data = bkin_bl__menu._data or {}


function bkin_bl__menu:init()
	-- Load the user options
	self:Load()

	-- The new player limit is defined here, it should not be greater than
	-- the max values set in the pdmod file.
	self._constants = {}
	self._constants.MAX_SLOTS       = 128
	self._constants.UNIQUE_HEISTERS = 21
	self._data.lobby_size           = self._data.lobby_size      or self._constants.UNIQUE_HEISTERS
	self._data.allow_more_bots      = self._data.allow_more_bots
	self._data.num_bots             = self._data.num_bots        or self._constants.UNIQUE_HEISTERS
	self._data.auto_stop_all_bots   = self._data.auto_stop_all_bots

	-- Apply 'settings' values to BigLobbyGlobals
	BigLobbyGlobals.num_players_settings     	= self._data.lobby_size
	BigLobbyGlobals.allow_more_bots_settings 	= self._data.allow_more_bots
	BigLobbyGlobals.num_bots_settings        	= self._data.num_bots
	BigLobbyGlobals.auto_stop_all_bots_settings = self._data.auto_stop_all_bots

	-- Register the hooks for creating the option menu
	self:RegisterHooks()
end


function bkin_bl__menu:Save()
	local file = io.open( self._data_path, "w+" )

	if file then
		local json_enc = json.encode( self._data )

		-- Prevents BLT crash bug when trying to parse empty brackets [], empty braces {} are fine though
		file:write( json_enc ~= "[]" and json_enc or "{}" )
		file:close()
	end
end


function bkin_bl__menu:Load()
	local file = io.open( self._data_path, "r" )

	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
	end
end


function bkin_bl__menu:RegisterHooks()
	Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit__bkin_bl", function( loc )
		loc:load_localization_file(BigLobbyGlobals.ModPath .. "l10n/en.json")
	end)


	Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus__bkin_bl", function( menu_manager, nodes )
		MenuHelper:NewMenu( self.menu_id )
	end)


	-- Menu Components and Callbacks
	Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus__bkin_bl", function( menu_manager, nodes )
		--Callbacks update data used by mod and for saving to file after user changes value
		MenuCallbackHandler.bkin_bl__set_size__clbk = function(menu_clbk, item)
			local num = math.floor( item:value() )

			item:set_value(num)                        -- Update the slider display to avoid floating point numbers
			self._data.lobby_size = num                -- Update so it can be saved
			BigLobbyGlobals.num_players_settings = num -- The variable that BigLobby references

			self:Save()
		end

		MenuCallbackHandler.bkin_bl__allow_more_bots__clbk = function(menu_clbk, item)
			local allow = ( item:value() == "on" and true or false )

			item:set_value(allow)
			self._data.allow_more_bots = allow
			BigLobbyGlobals.allow_more_bots_settings = allow

			self:Save()
		end
		
		MenuCallbackHandler.bkin_bl__set_num_bots__clbk = function(menu_clbk, item)
			local num = math.floor( item:value() )

			item:set_value(num)
			self._data.num_bots = num
			BigLobbyGlobals.num_bots_settings = num

			self:Save()
		end
		
		MenuCallbackHandler.bkin_bl__auto_stop_all_bots__clbk = function(menu_clbk, item)
			local allow = ( item:value() == "on" and true or false )

			item:set_value(allow)
			self._data.auto_stop_all_bots = allow
			BigLobbyGlobals.auto_stop_all_bots_settings = allow

			self:Save()
		end


		MenuHelper:AddSlider({
			id         = "lobby_size", --ID only needs to be unique in the scope of the options node we are creating
			title      = "bkin_bl__set_size__title",
			desc       = "bkin_bl__set_size__desc",
			callback   = "bkin_bl__set_size__clbk",
			value      = self._data.lobby_size,
			min        = 4,
			max        = 128,
			step       = 1,
			show_value = true,
			menu_id    = self.menu_id,
			priority   = 20
		})

		MenuHelper:AddToggle({
			id       = "num_bots_toggle",
			title    = "bkin_bl__allow_more_bots__title",
			desc     = "bkin_bl__allow_more_bots__desc",
			callback = "bkin_bl__allow_more_bots__clbk",
			value    = self._data.allow_more_bots,
			menu_id  = self.menu_id,
			priority = 30
		})

		MenuHelper:AddSlider({
			id         = "num_bots",
			title      = "bkin_bl__set_num_bots__title",
			desc       = "bkin_bl__set_num_bots__desc",
			callback   = "bkin_bl__set_num_bots__clbk",
			value      = self._data.num_bots,
			min        = 3,
			max        = 128,
			step       = 1,
			show_value = true,
			menu_id    = self.menu_id,
			priority   = 10
		})
		
		MenuHelper:AddToggle({
			id       = "auto_stop_all_bots_toggle",
			title    = "bkin_bl__auto_stop_all_bots__title",
			desc     = "bkin_bl__auto_stop_all_bots__desc",
			callback = "bkin_bl__auto_stop_all_bots__clbk",
			value    = self._data.auto_stop_all_bots,
			menu_id  = self.menu_id,
			priority = 6
		})
		
		local mod = BLT.Mods.GetModOwnerOfFile and BLT.Mods:GetModOwnerOfFile(BigLobbyGlobals.ModPath) or BLT.Mods.GetMod and BLT.Mods:GetMod("BigLobby3-master")
		if not mod then
			return
		end
		  
		BLT.Keybinds:register_keybind(mod, { id = "bkin_bl__stop_all_bots", allow_game = true, show_in_menu = false, callback = function()
			for _, ai in pairs(managers.groupai:state():all_AI_criminals()) do
				ai.unit:movement():set_should_stay(true)
			end
		end })
		local bind = BLT.Keybinds:get_keybind("bkin_bl__stop_all_bots")
		local key = bind and bind:Key() or ""
		  
		MenuHelper:AddKeybinding({
			id = "bkin_bl__stop_all_bots",
			title = "bkin_bl__stop_all_bots__title",
			desc= "bkin_bl__stop_all_bots__desc",
			connection_name = "bkin_bl__stop_all_bots",
			binding = key,
			button = key,
			menu_id = self.menu_id,
			priority = 5
		})
		  
		BLT.Keybinds:register_keybind(mod, { id = "bkin_bl__release_all_bots", allow_game = true, show_in_menu = false, callback = function()
			for _, ai in pairs(managers.groupai:state():all_AI_criminals()) do
				ai.unit:movement():set_should_stay(false)
			end
		end })
		local bind = BLT.Keybinds:get_keybind("bkin_bl__release_all_bots")
		local key = bind and bind:Key() or ""
		  
		MenuHelper:AddKeybinding({
			id = "bkin_bl__release_all_bots",
			title = "bkin_bl__release_all_bots__title",
			desc= "bkin_bl__release_all_bots__desc",
			connection_name = "bkin_bl__release_all_bots",
			binding = key,
			button = key,
			menu_id = self.menu_id,
			priority = 4
		})
	end)


	Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus__bkin_bl", function(menu_manager, nodes)
		nodes[self.menu_id] = MenuHelper:BuildMenu( self.menu_id )
		MenuHelper:AddMenuItem( nodes["blt_options"], self.menu_id, "bkin_bl__menu__title", "bkin_bl__menu__desc", 1 )
	end)
end