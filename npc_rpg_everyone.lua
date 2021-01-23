local launcher = nil
local firing = nil
local fready = false
local combinetable = {}
local enemytable = {}
local enemyinsight = false
local flMinTargetDist = 150
local flNavGoalTolerance = 10
local bShouldRun = true
local enemy = nil
local i = 1
local unitHealth = nil
function Spawn()
    thisEntity:SetContextThink(nil, Detect, 0)
end
function Activate()
    thisEntity:RegisterAnimTagListener( AnimTagListener)
end


function AnimTagListener( sTagName, nStatus)
    print (" AnimTag: ", sTagName, "Status: " , 1)
    if sTagName == "firing_ready" and nStatus == 1 then fready = true
    end
end

function HideGun()
    smg = Entities:FindAllByClassnameWithin("weapon_smg1",thisEntity:GetAbsOrigin(), 10)
    
    EntFireByHandle(thisEntity, smg[1], "Alpha", "0")
end

function HideGrenade()
    
    nade = Entities:FindAllByClassnameWithin("item_hlvr_grenade_frag",thisEntity:GetAbsOrigin(), 10)
    nadehandle = Entities:FindAllByNameWithin("grenade_handle",thisEntity:GetAbsOrigin(), 10)
    EntFireByHandle(thisEntity, nade[1], "Alpha", "0")
    EntFireByHandle(thisEntity, nadehandle[1], "Alpha", "0")
end



function GetEnts()             
    
    combinetable = Entities:FindAllByNameWithin("*cmb*",thisEntity:GetOrigin(),1024)
   
    unit = combinetable[1]
    
    enemytable = Entities:FindAllByClassnameWithin("*npc_*",thisEntity:GetOrigin(),2048)
end 
function Detect()
    GetEnts()
        if enemytable ~= nil then
            print("entities found")
            for key, val in pairs(enemytable) do 
                if val ~= nil then
                local squad = val:GetSquad()
                print(squad)
                end
                local EnemyInSight = thisEntity:ScriptLookupAttachment("eyes")
                local traceTable = 
                {
                    startpos = thisEntity:GetAttachmentOrigin(EnemyInSight);
                    endpos = val:GetOrigin() + Vector (0,0,35);
                    ignore = thisEntity;
                }
                TraceLine(traceTable)
                if squad ~= nil then
                    if (squad == "citsquad") and val:GetClassname() == "npc_combine_s" and val:GetHealth() > 0 and traceTable.enthit == val then 
                        enemypresent = true
                        enemy = val 
                        print(enemy)
                        RPGUsage()
                    end
                end   
            end
        return 1
    end
end


function RPGUsage()
    print("Startingrpg")
    
    if enemypresent == true then
        local flDistToTarget = ( enemy:GetAbsOrigin() - thisEntity:GetAbsOrigin() ):Length()
        if ( flDistToTarget < flMinTargetDist) and (thisEntity:NpcNavGoalActive()) then 
             thisEntity:NpcNavClearGoal()
        end
        if (not thisEntity:NpcNavGoalActive()) then
            CreatePathToTarget(enemy)
        end
        combat = thisEntity:GetGraphParameter("b_combat")
        strafe = thisEntity:GetGraphParameter("b_strafe")
        rpg = Entities:FindByName(nil, "*419_rpg*")
        print("Ready to fire")
        
        if (fready == true) and (combat == true) and (strafe ==false) then
            thisEntity:SetGraphLookTarget(enemy:GetAbsOrigin())
            thisEntity:SetGraphParameterBool("b_crouch",true)
            thisEntity:SetGraphParameterFloat("f_crouch",1.00)
            thisEntity:SetGraphParameterFloat("f_duck",1.00)
            thisEntity:SetGraphParameterEnum("e_stagger",12)
            print("I CAN FIRE")
            rpg:EmitSound("RapidFire.TagDartCharging")
            rpg:SetThink(function() return RPGSOUND(rpg) end, "chargeup", .5)
            NPCSPEECH()
            launcher = Entities:FindByName(nil,"*maker_bomb*")    
            print(launcher)
            print("launched")
            RPGEFFECT()
            EntFireByHandle(thisEntity, launcher, "ForceSpawn")
        else 
            print("can't shoot shit buddy") 
           
        end
    else
    end
end



function NPCSPEECH()
    combine = Entities:FindByName(nil, "*419_cmb*")
    EntFireByHandle(thisEntity, combine ,"cancelspeech")
    thisEntity:EmitSound("vo.combine.grunt.announceattack_grenade_09")
end

function RPGEFFECT()
    
 local ParticleID = ParticleManager:CreateParticle("particles/weapon_fx/muzzleflash_heavy_shotgun_a.vpcf", PATTACH_ABSORIGIN, rpg)
end 








function CreatePathToTarget( enemy ) 

	-- Find the vector from this entity to the player
	local vVecToEnemyNorm = ( enemy:GetAbsOrigin() - thisEntity:GetAbsOrigin() ):Normalized()

	-- Then find the point along that vector that is flMinPlayerDist from the player
	local vGoalPos = thisEntity:GetAbsOrigin() - ( vVecToEnemyNorm * flMinTargetDist );

	-- Create a path to that goal.  This will replace any existing path
	-- The path gets sent to the AnimGraph, and its up to the graph to make the character
	-- walk along the path
	thisEntity:NpcForceGoPosition( vGoalPos, bShouldRun, flNavGoalTolerance )
end        



function RPGSOUND(rpg)
    print("Soundon")
    return rpg
end

