-- tf_items
if !file.Exists("scripts/items/items_game.txt", "tf") then
    Error("ERROR: items_game.txt NOT FOUND!\nLIVE TF WEAPONS WILL NOT BE LOADED!\n")
end

local items_game = util.KeyValuesToTable(file.Read("scripts/items/items_game.txt", "tf"))

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
    elseif v.item_class == "tf_weapon_sniperrifle_classic" then
        v.item_class = "tf_weapon_sniperrifle"
    elseif v.item_class == "tf_weapon_sniperrifle_decap" then
        v.item_class = "tf_weapon_sniperrifle"
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

        if v.name == "Tomislav" then
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