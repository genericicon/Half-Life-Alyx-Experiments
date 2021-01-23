local enemy = {}
local CombatStatus = false
local MaxHealth 
local hp = 0
local rlstarttime = 0
local zcom = 0
local ccom = 0
local hcom = 0
local acom = 0
local idleTime = Time()
local unitdown = 0
local Squad = {}
local thinkvar = 2
local deploytimeremaining = 1
local mp7wep = nil
local smg = nil
local nade = nil
local nadehandle = nil
local i = 1
local NadePanicVar = .5
local nadepanicval = 0
local grunt = {}
local NadesInRadius = {}
local ix = 1
local CloseNade = nil
local EnemyChoice = nil
local mathtable = {10,15,5,25,30,35,40} 
local mathrandom = mathtable[randind]
function Spawn()
    thisEntity:SetContextThink(nil, MainThinker, 0)
    thisEntity:SetThink(HideItems, "HideItems", 0)
end

function Activate()
    --print("metrocop audio enabled")
    MaxHealth = thisEntity:GetHealth()
    thisEntity:RegisterAnimTagListener( AnimTagListener )
    thisEntity:SetThink(TakingDamage,"TakingDamage", 0)
    thisEntity:SetThink(CombatIdle,"CombatIdle",11)
    thisEntity:SetThink(SquadMemberLost, "SquadMemberLost", 0)
    thisEntity:SetThink(ReconAlert, "ReconAlert", 5)
    thisEntity:SetThink(MemberLostRe, "MemberLostRe", 5)
    thisEntity:SetThink(SoundReplace, "SoundReplace", 0)
    thisEntity:SetThink(NadePanic2, "NadePanic2", 0)
    thisEntity:SetThink(NadePaniked,"NadePaniked",0)
    thisEntity:SetThink(NadeFinder,"NadeFinder", 0)
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
    --print(nade)
    nade:SetRenderAlpha(0)
    nadehandle = Entities:FindByClassnameNearest("prop_physics",thisEntity:GetAbsOrigin(),72)
    --print(nadehandle)
    nadehandle:SetRenderAlpha(0)

end


function HideGun()
    smg = Entities:FindByClassnameNearest("*weapon_ar2*",thisEntity:GetAbsOrigin(),50)
    --print(smg)
    smg:SetRenderAlpha(0)
end

function AnimTagListener( sTagName, nStatus )
    --print( " AnimTag: ", sTagName, " Status: ", nStatus )
    if sTagName == "Finished_Reload" and nStatus == 1 then
        Reloading()
    end
    if sTagName == "Finished_Reload" and nStatus == 2 then
        rlstarttime = 0 
    end 
    if sTagName == "Finished_ThrowGrenade" and nStatus == 1 then
        DeployGrenade()
    end
    if sTagName == "Finished_ThrowGrenade" and nStatus == 2 then
        deploys = 0
    end 
    if sTagName == "weapon_fired" and nStatus == 1 then fready = true
    end
end
function MainThinker()
    if thisEntity:IsAlive() == true then
        randind = math.random(1,7)
        mathrandom = mathtable[randind]
        CheckForCombat()
        return .5
    
    else
        OnDeath()
        --print("Ended")
        thisEntity:StopThink("MainThinker")
            
    end 
end 



function OnDeath()
    thisEntity:EmitSound("f_citizen_death")
    thisEntity:StopThink("SquadMemberLost")
end 


function CheckForCombat()
    CombatStatus = thisEntity:GetGraphParameter("b_combat")
    WalkStatus = thisEntity:GetGraphParameter("b_walking")
    if CombatStatus == true and WalkStatus == false then
        randind = math.random(1,7)
        GetCombatContext()   
    else 
        --IM IDLE
    end 
        
        
end 




function GetCombatContext()
    enemy = Entities:FindAllByClassnameWithin("*npc*",thisEntity:GetAbsOrigin(),1024) 
    if enemy ~= nil and enemy ~= 2 then
        for key, val in pairs(enemy) do 
            local EnemyInSight = thisEntity:ScriptLookupAttachment("eyes")
            local traceTable = 
            {
                startpos = thisEntity:GetAttachmentOrigin(EnemyInSight);
                endpos = val:GetOrigin() + Vector (0,0,35);
                ignore = thisEntity;
            }
            TraceLine(traceTable)
            if (val:GetClassname() == "npc_zombie") and val:GetHealth() > 0 and traceTable.enthit == val then
                EnemySpeechZombie()
                
            end
            if (val:GetClassname() == "npc_combine_s") and val:GetHealth() > 0 and traceTable.enthit == val then
                EnemySpeechCitizen()
                
            end
            if (val:GetClassname() == "npc_headcrab") and val:GetHealth() > 0 and traceTable.enthit == val then
                EnemySpeechHeadcrab()
                
            end
            if (val:GetClassname() == "npc_antlion") and val:GetHealth() > 0 and traceTable.enthit == val then
                EnemySpeechAntlion()
            end
        end 
    end 
end 
    
function TakingDamage()
    Health = thisEntity:GetHealth()
    if Health < MaxHealth then 
        MaxHealth = Health
        thisEntity:EmitSound("f_citizen_pain")
        IsHealthLow()
    end 
    return .5
end

function Reloading()
    if rlstarttime == 0 then
        reloadstatus = thisEntity:GetGraphParameter("b_reload")
        if reloadstatus == true then
            thisEntity:EmitSound("f_citizen_reloading")
            rlstarttime = 1
        end 
    end
end 
function IsHealthLow()
    if hp == 0 then
        injuredstatus = thisEntity:GetGraphParameter("b_injured")
        if injuredstatus == true then 
            --print("I'm Really Injured")
            thisEntity:EmitSound("f_citizen_pain")
            hp = hp + 1
        end 
    end 
end



function EnemySpeechZombie()
    
    zcom = zcom + 1
    if zcom == 1 then 
    thisEntity:EmitSound("f_citizen_sees_zombies")
        zcom = zcom + 1
        --print("I SEE A ZOMBIE")
    end 
end 

function EnemySpeechCitizen()
    
    ccom = ccom + 1
    if ccom == 1 then 
    thisEntity:EmitSound("f_citizen_sees_combine")
        ccom = ccom + 1
        --print("I SEE A CITIZEN")
    end 
end
function EnemySpeechHeadcrab()
   
    hcom = hcom + 1
    if hcom == 1 then 
    thisEntity:EmitSound("f_citizen_sees_headcrabs")
        hcom = hcom + 1
        --print("I SEE A HEADCRAB")
    end 
end
function EnemySpeechAntlion()
    
    acom = acom + 1
    if acom == 1 then 
    thisEntity:EmitSound("vo.combine.grunt.announceenemy_antlion_02")
        acom = acom + 1
        --print("I SEE AN ANTLION")
    end 
end


function CombatIdle()
if CombatStatus == true then
        if idleTime + math.random(1,5) < Time() then
            --print("Checking for idle sounds")
            local randomchoice = math.random(1,3)
            if zcom > 1 then 
                if randomchoice == 1 then thisEntity:EmitSound("f_citizen_is_ready") end
                if randomchoice == 2 then thisEntity:EmitSound("f_citizen_combat") end
                if randomchoice == 3 then thisEntity:EmitSound("f_citizen_sees_zombies") end
            elseif ccom > 1 then
                if randomchoice == 1 then thisEntity:EmitSound("f_citizen_combat") end
                if randomchoice == 2 then thisEntity:EmitSound("f_citizen_is_ready") end
                if randomchoice == 3 then thisEntity:EmitSound("f_citizen_sees_combine") end
            elseif hcom > 1 then
                if randomchoice == 1 then thisEntity:EmitSound("f_citizen_combat") end
                if randomchoice == 2 then thisEntity:EmitSound("f_citizen_is_ready") end
                if randomchoice == 3 then thisEntity:EmitSound("f_citizen_sees_headcrabs") end
            elseif acom > 1 then
                if randomchoice == 1 then thisEntity:EmitSound("") end
                if randomchoice == 2 then thisEntity:EmitSound("") end
                if randomchoice == 3 then thisEntity:EmitSound("") end
            end
        end
        return mathrandom
    end
end 

function ReconAlert()
    if CombatStatus == false then
        if idleTime + math.random(1,5) < Time() then
            --print("IDLING")
                local randomchoice = math.random(1,3)
                if randomchoice == 1 then thisEntity:EmitSound("f_citizen_idle") end
                if randomchoice == 2 then thisEntity:EmitSound("f_citizen_idle") end
                if randomchoice == 3 then thisEntity:EmitSound("f_citizen_idle") end
            end    
        return mathrandom 
    end
end 


function SquadMemberLost()
Squad = Entities:FindAllByClassnameWithin("npc_combine_s",thisEntity:GetAbsOrigin(),512)
--print("checkingfordown")

    for key, val in pairs(Squad) do
        if val:IsAlive() == false then
            unitdown = 1
        end
    end
    if unitdown == 1 then
        thisEntity:EmitSound("f_citizen_squad_member_down")
        unitdown = 0
        
        thinkvar = 5
    end

    return thinkvar
end
    
function MemberLostRe()
    if thinkvar == 5 then
        thinkvar = 1
        returnvar = 2
    else
    end
    return returnvar
end

    
function DeployGrenade()
    if deploys == 0 then 
        Deploying = thisEntity:GetGraphParameter("b_throw_grenade")
        if Deploying == true then
            thisEntity:EmitSound("f_citizen_is_ready")
            deploys = 0
        end
    end
end
    
   
    
        
function SoundReplace()
    if thisEntity:IsAlive() == true then
        mp7wep = Entities:FindByModelWithin(nil,"models/weapons/v_rif_ak47.vmdl",thisEntity:GetAbsOrigin(),300)
        --print(mp7wep)
        firing = thisEntity:GetGraphParameter("b_firing")
        signal = thisEntity:GetGraphParameter("b_signal")
        if fready == true and firing == true and signal == false then 
            local mp7attach = mp7wep:ScriptLookupAttachment("1")
            local mp7attachpos = mp7wep:GetAttachmentOrigin(mp7attach)

            StartSoundEventFromPosition("ak_sound",mp7attachpos)
        
            local particle = ParticleManager:CreateParticle("particles/weapon_fx/muzzleflash_smg_heavy_fire.vpcf", PATTACH_POINT, mp7wep)
            ParticleManager:SetParticleControlEnt(particle, 0, mp7wep, PATTACH_POINT, "1", Vector(0,0,0),false)
        end
    
    
    return .12
    else 
    thisEntity:StopThink("SoundReplace")
    end
end 

function NadePanic2()
    nearestfrag = Entities:FindByClassnameNearest("item_hlvr_grenade_frag",thisEntity:GetAbsOrigin(),512)
    if nearestfrag ~= nil then
        currentseq = nearestfrag:GetSequence()
        --print(currentseq)
        if currentseq == "vr_grenade_arm_idle" and nadepanicval == 0 then 
            thisEntity:EmitSound("f_citizen_combat")
            --print("soundchanged")
            nadepanicval = 1
            NadePanicVar = 5
        end
    end
    return NadePanicVar
end

function NadePaniked()
    if NadePanicVar == 5 then
        NadePanicVar = 1
        nadepanicval = 0
        returnvar2 = 2
    else
    end
    return returnvar2
end


function NadeFinder()
    if thisEntity:IsAlive() then
        --print("is active")
        EnemyChoice = Entities:FindAllByNameWithin("*npc*",thisEntity:GetAbsOrigin(),1024)
        grunt = Entities:FindAllByClassnameWithin("npc_combine_s",thisEntity:GetAbsOrigin(),10)
        
        CloseNade = Entities:FindAllByNameWithin("*attacheditem_0*",thisEntity:GetAbsOrigin(),50)
        --print(CloseNade)
        NadesInRadius = Entities:FindAllByClassnameWithin("item_hlvr_grenade_frag",thisEntity:GetAbsOrigin(),65)
        if #NadesInRadius > 1 then 
            ix = 1
        end
            local drop = thisEntity:GetGraphParameter("b_throw_grenade")
            local throw = thisEntity:GetGraphParameter("b_dropgrenade")
            if drop == true or throw == true then
                ix = 2 
            else    
                ix = 1
            end 
        --print (#NadesInRadius)
        NadeToRemove = NadesInRadius[ix]
        
        if #NadesInRadius >1 then 
            ix = ix + 1 
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
    if  ix == 2 and NadeToRemove ~= CloseNade[1] and NadeToRemove ~= CloseNade[ix] and modelstate == "vr_grenade_arm_idle"  then 
        UTIL_Remove(NadeToRemove)
        EntFireByHandle(thisEntity,thisEntity,"ThrowGrenadeAtTarget",Index)
        thisEntity:EmitSound("CombineUpgradeStation.WeaponGrab")
    else 
        --print("well fuck") 
    end
end


function FindIndex()
    Index = EnemyChoice[ix]:GetName()
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
            ix = nil
        end
    else
    end
end

