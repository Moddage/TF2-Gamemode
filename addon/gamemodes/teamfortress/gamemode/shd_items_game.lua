-- tf_items
if !file.Exists("scripts/items/items_game.txt", "GAME") then
    Error("ERROR: items_game.txt NOT FOUND!\nLIVE TF WEAPONS WILL NOT BE LOADED!\n")
end

local items_game = util.KeyValuesToTable(file.Read("scripts/items/items_game.txt", "GAME")) 

for k, v in pairs(items_game["items"]) do
    if v.prefab and string.find(v.prefab, " ") then
        local tab = string.Split(v.prefab, " ")
        for i, o in pairs(tab) do
            if string.find(o, "weapon") then
                v.prefab = o
            end
        end
    end

    if v.prefab and items_game["prefabs"][v.prefab] then
        for i, o in pairs(items_game["prefabs"][v.prefab]) do
            if !v[i] then
                v[i] = o
            end 
        end
    end

    v.id = k
    v.propername = 0

    if v.item_class == "saxxy" then
        v.item_class = "tf_weapon_allclass"
    elseif v.item_class == "tf_weapon_grenadelauncher" then
		v.item_slot = "secondary"
    elseif v.item_class == "tf_weapon_pipebomblauncher" then
		v.item_slot = "primary"
    elseif v.item_class == "tf_weapon_sniperrifle_classic" then
        v.item_class = "tf_weapon_sniperrifle"
    elseif v.item_class == "tf_weapon_sniperrifle_decap" then
        v.item_class = "tf_weapon_sniperrifle"
    elseif v.item_class == "tf_weapon_pep_brawler_blaster" then
        v.item_class = "tf_weapon_scattergun"
    elseif v.item_class == "tf_weapon_shotgun" then
        v.item_class = "tf_weapon_shotgun_soldier"
    elseif v.item_class == "tf_wearable_demoshield" then
        v.item_class = "tf_wearable_item_demoshield"
    elseif v.item_class == "tf_weapon_particle_cannon" then
        v.item_class = "tf_weapon_particle_launcher"
    elseif v.item_class == "tf_weapon_handgun_scout_secondary" then
        v.item_class = "tf_weapon_pistol_scout"
    elseif v.item_class == "tf_weapon_laser_pointer" then
        v.item_class = "tf_weapon_wrangler"
    elseif v.item_class == "tf_weapon_sapper" then
        v.item_class = "tf_weapon_builder"
    elseif v.item_class == "tf_weapon_soda_popper" then
        v.item_class = "tf_weapon_scattergun"
    end

    if !v.item_class then
        v.item_class = "tf_wearable_item"
    end

    if k == 513 then
        v.item_class = "tf_weapon_rocketlauncher_qrl"
		elseif k == 20 then
			v.item_slot = "primary"
		elseif k == 19 then
        v.item_slot = "secondary"
    end

    if v.id == 424 then print(tf_lang.GetRaw(v.item_name)) end

    if v.item_name then
        v.name = tf_lang.GetRaw(v.item_name)
        tf_items.Items[v.name] = v
  
        if v.name == "Natascha" then
			v.item_class = "tf_weapon_minifun"
		end
        if v.name == "Deflector" then
			v.item_class = "tf_weapon_minigun_mvm"
		end
        if v.name == "Huo-Long Heater" then
			v.item_class = "tf_weapon_minigun_burner"
		end
        if v.name == "Red-Tape Recorder" then
			v.item_class = "tf_weapon_rtr" 
		end
        if v.name == "Half-Zatoichi" then
			v.item_class = "tf_weapon_katana"
        end
        if v.name == "Concheror" then
			v.item_class = "tf_weapon_buff_item_conch"
		end
        if v.name == "Sharp Dresser" then
			v.item_class = "tf_weapon_knife_sh"
        end
        if v.name == "Backburner" then
			v.item_class = "tf_weapon_flamethrower_bb"
        end
        if v.name == "Degreaser" then
			v.item_class = "tf_weapon_flamethrower_dg"
        end
        if v.name == "Rainblower" then
			v.item_class = "tf_weapon_flamethrower_rb"
        end
        if v.name == "Quick-Fix" then
			v.item_class = "tf_weapon_medigun_qf"
		end
        if v.name == "Family Business" then
			v.item_class = "tf_weapon_shotgun_hwg"
		end
        if v.name == "Vaccinator" then
			v.item_class = "tf_weapon_medigun_vaccinator"
		end
        if v.name == "Beggar's Bazooka" then
			v.item_class = "tf_weapon_rocketlauncher_rapidfire"
        end
        if v.name == "Phlogistinator" then
            v.item_class = "tf_weapon_phlogistinator"
        end
        if v.name == "Widowmaker" then
			v.item_class = "tf_weapon_shotgun_imalreadywidowmaker"
		end
        if v.name == "Spy-cicle" then
			v.item_class = "tf_weapon_knife_icicle" 
        end
        if v.name == "Escape Plan" then
			v.item_class = "tf_weapon_pickaxe" 
		end
        if v.name == "Tomislav" then
			v.item_class = "tf_weapon_minigun_tomislav"
            print("Tomislav Time")
        end
    elseif v.name then
        tf_items.Items[tf_lang.GetRaw(v.name)] = v
    else
        v.name = "Test " .. math.random(30000)
        tf_items.Items[v.name] = v
    end

    tf_items.ItemsByID[v.id] = v
end

tf_items.Items.n = #items_game["items"]