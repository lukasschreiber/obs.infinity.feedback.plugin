obs           = obslua
key 		  = "a9647307967b2ee4252f2f02b92588fb0ed3279e"
server		  = "https://allinthebox.org/ch/app/"

hotkey_id     = obs.OBS_INVALID_HOTKEY_ID

function get_current_scene()
	local current_scene = obs.obs_frontend_get_current_scene()
	local current_scene_name = obs.obs_source_get_name(current_scene)


	local all_scenes = obs.obs_frontend_get_scene_names()
	local all_scenes_list = table.concat(all_scenes, ",")

	print("All: " .. table.concat(all_scenes, ","))
	print("Current: " .. current_scene_name)

	local params = "\"".."key="..urlencode(key).."&all="..urlencode(all_scenes_list).."&active="..urlencode(current_scene_name).."\""
	local url = "\""..server.."update_scenes.php".."\""
	local command = "start /B curl -d "..params.." "..url
	--print(command)
	os.execute(command)
end

function urlencode (str)
	str = string.gsub (str, "([^0-9a-zA-Z !'()*._~-])", -- locale independent
	   function (c) return string.format ("%%%02X", string.byte(c)) end)
	str = string.gsub (str, " ", "+")
	return str
 end

----------------------------------------------------------

-- A function named script_properties defines the properties that the user
-- can change for the entire script module itself
function script_properties()
	local props = obs.obs_properties_create()
	obs.obs_properties_add_text(props, "server_address", "Server Address", obs.OBS_TEXT_DEFAULT)
	obs.obs_properties_add_text(props, "key", "Key", obs.OBS_TEXT_DEFAULT)

	return props
end

-- A function named script_description returns the description shown to
-- the user
function script_description()
	return "Calls the API whenever the active Scene is updated.\n\nMade by Lukas Schreiber"
end

-- A function named script_update will be called when settings are changed
function script_update(settings)

	server = obs.obs_data_get_string(settings, "server_address")
	key = obs.obs_data_get_string(settings, "key")

end

-- A function named script_defaults will be called to set the default settings
function script_defaults(settings)
	obs.obs_data_set_default_string(settings, "server_address", "https://allinthebox.org/ch/app/")
end

-- A function named script_save will be called when the script is saved
--
-- NOTE: This function is usually used for saving extra data (such as in this
-- case, a hotkey's save data).  Settings set via the properties are saved
-- automatically.
function script_save(settings)
	
end

-- a function named script_load will be called on startup
function script_load(settings)
	-- Connect hotkey and activation/deactivation signal callbacks
	--
	-- NOTE: These particular script callbacks do not necessarily have to
	-- be disconnected, as callbacks will automatically destroy themselves
	-- if the script is unloaded.  So there's no real need to manually
	-- disconnect callbacks that are intended to last until the script is
	-- unloaded.
	local sh = obs.obs_get_signal_handler()
	--obs.signal_handler_connect(sh, "source_activate", get_current_scene)
	obs.signal_handler_connect(sh, "source_deactivate", get_current_scene)
	obs.signal_handler_connect(sh, "source_create", get_current_scene)
	obs.signal_handler_connect(sh, "source_remove", get_current_scene)

	print(package.path..'\n'..package.cpath)


	get_current_scene()
end
