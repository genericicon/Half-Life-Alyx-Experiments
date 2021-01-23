local smg = nil
local nade = nil
local nadehandle = nil
local i = 1
function Spawn()
    thisEntity:SetContextThink(nil, HideItems, 0)
   
    print("startingweaponhide")
end


function Activate()
    print("active")
    
    
end

function HideItems()
    if i ~= 3 then
        if i == 1 then 
            HideGun()
            i = i + 1
        else 
            HideGrenade()
            i = i + 1
        end 

        return 1
    else
        return nil
    end 
end 



function HideGrenade()
    nade = Entities:FindByClassnameNearest("item_hlvr_grenade_frag",thisEntity:GetAbsOrigin(),72)
    print(nade)
    nade:SetRenderAlpha(0)
    nadehandle = Entities:FindByClassnameNearest("prop_physics",thisEntity:GetAbsOrigin(),72)
    print(nadehandle)
    nadehandle:SetRenderAlpha(0)

end


function HideGun()
    smg = Entities:FindByClassnameNearest("weapon_smg1",thisEntity:GetAbsOrigin(),50)

    smg:SetRenderAlpha(0)
end