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
local mathtable = {10,15,5,25,30,35,40} 
local mathrandom = mathtable[randind]

function Spawn()
    thisEntity:SetContextThink(nil, MainThinker, 0)
    thisEntity:SetThink(HideItems, "HideItems", 0)
end

function Activate()
   -- print("metrocop audio enabled")
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
end

function HideItems()
    if i ~= 3 then
        if i == 1 then 
            
            HideGun()
            i = i + 1
        else 
            i = i + 1
        end 

        return 1
    else
        return nil
    end 
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
        DeployHack()
    end
    if sTagName == "Finished_ThrowGrenade" and nStatus == 2 then
        deploys = 0
    end 
    if sTagName == "weapon_fired" and nStatus == 1 then fready = true
    end
end
function MainThinker()
    me = Entities:FindByClassnameNearest("npc_combine_s",thisEntity:GetAbsOrigin(),1)
    if thisEntity:IsAlive() == true then
        randind = math.random(1,7)
        mathrandom = mathtable[randind]
        print (randind)
        print (mathrandom)
        CheckForCombat()
        return .5
    
    else
        OnDeath()
        print("Ended")
        thisEntity:StopThink("MainThinker")
            
    end 
end 



function OnDeath()
    thisEntity:EmitSound("metrocop_death")
    thisEntity:StopThink("SquadMemberLost")
end 


function CheckForCombat()
    CombatStatus = thisEntity:GetGraphParameter("b_combat")
    WalkStatus = thisEntity:GetGraphParameter("b_walking")
    if CombatStatus == true and WalkStatus == false then
  
        GetCombatContext()
    else 
        --IM IDLE
    end 
        
        
end 




function GetCombatContext()
    enemy = Entities:FindAllByClassnameWithin("*npc*",thisEntity:GetAbsOrigin(),1024) 
    if enemy ~= nil and enemy ~= thisEntity then
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
        thisEntity:EmitSound("metrocop_pain")
        IsHealthLow()
    end 
    return .5
end

function Reloading()
    if rlstarttime == 0 then
        reloadstatus = thisEntity:GetGraphParameter("b_reload")
        if reloadstatus == true then
            thisEntity:EmitSound("metrocop_radio_on")
            thisEntity:EmitSound("metrocop_reloading")
            thisEntity:EmitSound("metrocop_radio_off")
            rlstarttime = 1
        end 
    end
end 
function IsHealthLow()
    if hp == 0 then
        injuredstatus = thisEntity:GetGraphParameter("b_injured")
        if injuredstatus == true then 
            --print("I'm Really Injured")
            thisEntity:EmitSound("metrocop_radio_on") 
            thisEntity:EmitSound("metrocop_islow")
            thisEntity:EmitSound("metrocop_radio_off")
            hp = hp + 1
        end 
    end 
end



function EnemySpeechZombie()
    
    zcom = zcom + 1
    if zcom == 1 then 
    thisEntity:EmitSound("metrocop_radio_on")    
    thisEntity:EmitSound("metrocop_sees_zombies")
    thisEntity:EmitSound("metrocop_radio_off")
        zcom = zcom + 1
        --print("I SEE A ZOMBIE")
    end 
end 

function EnemySpeechCitizen()
    
    ccom = ccom + 1
    if ccom == 1 then
    thisEntity:EmitSound("metrocop_radio_on") 
    thisEntity:EmitSound("metrocop_sees_citizen")
    thisEntity:EmitSound("metrocop_radio_off")
        ccom = ccom + 1
        --print("I SEE A CITIZEN")
    end 
end
function EnemySpeechHeadcrab()
   
    hcom = hcom + 1
    if hcom == 1 then
    thisEntity:EmitSound("metrocop_radio_on") 
    thisEntity:EmitSound("metrocop_sees_headcrabs")
        hcom = hcom + 1
        --print("I SEE A HEADCRAB")
    end 
end
function EnemySpeechAntlion()
    
    acom = acom + 1
    if acom == 1 then
    thisEntity:EmitSound("metrocop_radio_on") 
    thisEntity:EmitSound("vo.combine.grunt.announceenemy_antlion_02")
    thisEntity:EmitSound("metrocop_radio_off")
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
                if randomchoice == 1 then thisEntity:EmitSound("metrocop_radio_on") thisEntity:EmitSound("metrocop_combat") thisEntity:EmitSound("metrocop_radio_off") end 
                if randomchoice == 2 then thisEntity:EmitSound("metrocop_radio_on") thisEntity:EmitSound("metrocop_combat") thisEntity:EmitSound("metrocop_radio_off") end
                if randomchoice == 3 then thisEntity:EmitSound("metrocop_radio_on") thisEntity:EmitSound("metrocop_combat") thisEntity:EmitSound("metrocop_radio_off") end
            elseif ccom > 1 then
                if randomchoice == 1 then thisEntity:EmitSound("metrocop_radio_on") thisEntity:EmitSound("metrocop_combat") thisEntity:EmitSound("metrocop_radio_off") end  
                if randomchoice == 2 then thisEntity:EmitSound("metrocop_radio_on") thisEntity:EmitSound("metrocop_combat") thisEntity:EmitSound("metrocop_radio_off") end
                if randomchoice == 3 then thisEntity:EmitSound("metrocop_radio_on") thisEntity:EmitSound("metrocop_combat") thisEntity:EmitSound("metrocop_radio_off") end
            elseif hcom > 1 then
                if randomchoice == 1 then thisEntity:EmitSound("metrocop_radio_on") thisEntity:EmitSound("metrocop_combat") thisEntity:EmitSound("metrocop_radio_off") end
                if randomchoice == 2 then thisEntity:EmitSound("metrocop_radio_on") thisEntity:EmitSound("metrocop_combat") thisEntity:EmitSound("metrocop_radio_off") end
                if randomchoice == 3 then thisEntity:EmitSound("metrocop_radio_on") thisEntity:EmitSound("metrocop_combat") thisEntity:EmitSound("metrocop_radio_off")  end
            elseif acom > 1 then
                if randomchoice == 1 then thisEntity:EmitSound("metrocop_radio_on") thisEntity:EmitSound("metrocop_combat") thisEntity:EmitSound("metrocop_radio_off") end
                if randomchoice == 2 then thisEntity:EmitSound("metrocop_radio_on") thisEntity:EmitSound("metrocop_combat") thisEntity:EmitSound("metrocop_radio_off") end
                if randomchoice == 3 then thisEntity:EmitSound("metrocop_radio_on") thisEntity:EmitSound("metrocop_combat") thisEntity:EmitSound("metrocop_radio_off") end
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
                if randomchoice == 1 then thisEntity:EmitSound("metrocop_radio_on") thisEntity:EmitSound("metrocop_idle") thisEntity:EmitSound("metrocop_radio_off") end
                if randomchoice == 2 then thisEntity:EmitSound("metrocop_radio_on") thisEntity:EmitSound("metrocop_idle") thisEntity:EmitSound("metrocop_radio_off") end
                if randomchoice == 3 then thisEntity:EmitSound("metrocop_radio_on") thisEntity:EmitSound("metrocop_idle") thisEntity:EmitSound("metrocop_radio_off") end 
            end    
        return mathrandom 
    end
end 


function SquadMemberLost()
Squad = Entities:FindAllByClassnameWithin("npc_combine_s",thisEntity:GetAbsOrigin(),1024)
--print("checkingfordown")

    for key, val in pairs(Squad) do
        if val:IsAlive() == false then
            unitdown = 1
        end
    end
    if unitdown == 1 then
        thisEntity:EmitSound("metrocop_radio_on")
        thisEntity:EmitSound("metrocop_squad_member_down")
        thisEntity:EmitSound("metrocop_radio_off")
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

    
function DeployHack()
    if deploys == 0 then 
        Deploying = thisEntity:GetGraphParameter("b_manhack_deploy")
        if Deploying == true then
            thisEntity:EmitSound("metrocop_radio_on")
            thisEntity:EmitSound("metrocop_hackout")
            thisEntity:EmitSound("metrocop_radio_off")
            deploys = 0
        end
    end
end
    
function SoundReplace()
    if thisEntity:IsAlive() == true then
        mp7wep = Entities:FindByModelWithin(nil,"models/weapons/v_smg_mp7.vmdl",thisEntity:GetAbsOrigin(),72)
        firing = thisEntity:GetGraphParameter("b_firing")
        signal = thisEntity:GetGraphParameter("b_signal")
        if fready == true and firing == true and signal == false then 
            
            local mp7attach = mp7wep:ScriptLookupAttachment("1")
            local mp7attachpos = mp7wep:GetAttachmentOrigin(mp7attach)

            StartSoundEventFromPosition("mp7_sound",mp7attachpos)
        
            local particle = ParticleManager:CreateParticle("particles/weapon_fx/muzzleflash_smgs.vpcf", PATTACH_POINT, mp7wep)
            ParticleManager:SetParticleControlEnt(particle, 0, mp7wep, PATTACH_POINT, "1", Vector(0,0,0),false)
            

            
           
        --print("replacedsound")



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
            thisEntity:EmitSound("metrocop_radio_on")
            thisEntity:EmitSound("metrocop_avoidnade")
            thisEntity:EmitSound("metrocop_radio_off")
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


