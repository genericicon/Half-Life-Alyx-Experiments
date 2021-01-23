local grunt = {}
local NadesInRadius = {}
local i = 1
local CloseNade = nil
local EnemyChoice = nil
local playerlist = {}
local playerl = nil
function Spawn()
    thisEntity:SetContextThink(nil, NadeFinder, 0)
end



function NadeFinder()
    if thisEntity:IsAlive() then
        EnemyChoice = Entities:FindAllByNameWithin("*npc*",thisEntity:GetAbsOrigin(),1024)
        grunt = Entities:FindAllByClassnameWithin("npc_combine_s",thisEntity:GetAbsOrigin(),10)
        
        CloseNade = Entities:FindAllByNameWithin("*attacheditem_0*",thisEntity:GetAbsOrigin(),50)
        --print(CloseNade)
        NadesInRadius = Entities:FindAllByClassnameWithin("item_hlvr_grenade_frag",thisEntity:GetAbsOrigin(),65)
        if #NadesInRadius > 1 then 
            i = 1
        end
            local drop = thisEntity:GetGraphParameter("b_throw_grenade")
            local throw = thisEntity:GetGraphParameter("b_dropgrenade")
            if drop == true or throw == true then
                i = 2 
            else    
                i = 1
            end 
        --print (#NadesInRadius)
        NadeToRemove = NadesInRadius[i]
        if #NadesInRadius >1 then 
            i = i + 1 
        end 
        CheckIfAttachedItem()
        NadeEnder()
        
        --print(NadeToRemove)
    return .1
    else
    thisEntity:StopThink("NadeFinder")
    end 
end

function NadeEnder()
    if NadeToRemove ~= nil then
        modelstate = NadeToRemove:GetSequence()
    end
   
    if EnemyChoice[2] ~= nil and EnemyChoice[2] ~= grunt and EnemyChoice[2]:IsAlive() then
        --print("npc is target")
        TargetEntity = EnemyChoice[2]
        CheckIfFriendly()
    end 
    if  i == 2 and NadeToRemove ~= CloseNade[1] and NadeToRemove ~= CloseNade[i] and modelstate == "vr_grenade_arm_idle"  then 
        UTIL_Remove(NadeToRemove)
        EntFireByHandle(thisEntity,thisEntity,"ThrowGrenadeAtTarget",Index)
        thisEntity:EmitSound("CombineUpgradeStation.WeaponGrab")
    else 
        --print("well fuck") 
    end
end


function FindIndex()
    Index = EnemyChoice[i]:GetName()
end


function CheckIfFriendly()
    Friendly = EnemyChoice[2]:GetClassname()
    --print (Friendly)
    if Friendly == "npc_combine_s" or Friendly == "item_hlvr_grenade_frag" or Friendly == "ai_foot_sweep" then
        --print ("aborting")
     
    else
    FindIndex()
    end 
end 


function CheckIfAttachedItem()
    if NadeToRemove ~= nil then

        removenadename = NadeToRemove:GetName()
        if removenadename == "*attacheditem_0" then 
            i = nil
        end
    else
    end
end



    