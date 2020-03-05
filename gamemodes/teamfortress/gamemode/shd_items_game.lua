-- tf_items
if !file.Exists("scripts/items/items_game.txt", "tf") then
    Error("ERROR: items_game.txt NOT FOUND!\nLIVE TF WEAPONS WILL NOT BE LOADED!\nISSUES SUCH AS WEAPONS MISSING SOUNDS AND ANIMATIONS MAY OCCUR!")
end

local items_game = util.KeyValuesToTable(file.Read("scripts/items/items_game.txt", "tf"))
local prefabs = items_game["prefabs"]
local items = items_game["items"]

for k, v in pairs(items) do
    -- fix an issue where prefabs would sometimes be split up and invalid
    if v.prefab and string.find(v.prefab, " ") then
        local tab = string.Split(v.prefab, " ")
        for i, o in pairs(tab) do
            if string.find(o, "weapon") then
                v.prefab = o
            end
        end
    end

    -- load visuals
    if prefabs[v.prefab] and v.visuals then
        local prefab = prefabs[v.prefab]
        if prefab.visuals then
            local oldvisuals = v.visuals
            v.visuals = prefab.visuals
            table.Merge(v.visuals, oldvisuals)
        end
    end

    -- add prefab variables that don't exist
    if v.prefab and prefabs[v.prefab] then
        for i, o in pairs(prefabs[v.prefab]) do
            if !v[i] then
                v[i] = o
            end
        end
    end

    -- fix id and reset propername
    v.id = k
    v.propername = 0

    -- fix itemclass for certain weapons
    if v.item_class == "saxxy" then
        v.item_class = "tf_weapon_allclass"
    elseif v.item_class == "tf_weapon_sniperrifle_classic" then
        v.item_class = "tf_weapon_sniperrifle"
    elseif v.item_class == "tf_weapon_sniperrifle_decap" then
        v.item_class = "tf_weapon_sniperrifle"
    elseif v.item_class == "tf_weapon_pep_brawler_blaster" then
        v.item_class = "tf_weapon_scattergun"
    elseif v.item_class == "tf_weapon_rocketlauncher_fireball" then
        v.item_class = "tf_weapon_rocketlauncher"
    elseif v.item_class == "tf_weapon_flaregun_revenge" then
        v.item_class = "tf_weapon_flaregun"
    elseif v.item_class == "tf_weapon_katana" then
        v.item_class = "tf_weapon_sword"
    elseif v.prefab == "weapon_eyelander" or v.prefab == "weapon_sword" or (prefabs[v.prefab] and prefabs[v.prefab].prefab == "weapon_sword") then
        v.attach_to_hands = 1
        v.item_class = "tf_weapon_sword"
    end

    -- assume it's cosmetic if it has no class
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

    -- fix item names
    if v.item_name then
        v.name = tf_lang.GetRaw(v.item_name)
        tf_items.Items[v.name] = v
    elseif v.name then
        tf_items.Items[tf_lang.GetRaw(v.name)] = v
    else
        v.name = "Test " .. math.random(30000)
        tf_items.Items[v.name] = v
    end

    -- register it as a weapon
    tf_items.ItemsByID[v.id] = v
end

tf_items.Items.n = #items