-- slot fix

local specialslots = {}
specialslots["weapon_physgun"] = 5
specialslots["gmod_tool"] = 6

hook.Add("WeaponEquip", "TF_ItemSlotFix", function(wep, ply)
    timer.Simple(0, function()
        if !ply:IsHL2() then
            local newslot = (specialslots[wep:GetClass()] and specialslots[wep:GetClass()]) or wep.Slot or wep:GetSlot()
            for _, weps in pairs(ply:GetWeapons()) do
                local slot = (specialslots[weps:GetClass()] and specialslots[weps:GetClass()]) or weps.Slot or weps:GetSlot()
                if weps ~= wep and slot == newslot then
                    ply:StripWeapon(weps:GetClass())
                end
            end
        end
    end)
end)