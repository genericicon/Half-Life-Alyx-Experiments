local door
local soldier
local bShouldRun = true
local flNavGoalTolerance = 5
local flDisttoNPC 
local flMinNpcDist = 35
local flRepathTime = 1.0
local flLastPathTime = 0.0
local i = 0
local UNITABLE = {}
local DOORSTATUSTABLE = {}
local lastval = nil
function Spawn()
    print("breacher active")
    thisEntity:SetContextThink(nil,DoorThinker,0)
end






function DoorThinker()
    if thisEntity:IsAlive() == true then
        soldier = Entities:FindByClassnameNearest("npc_combine_s",thisEntity:GetAbsOrigin(),10)
        print(soldier:GetName())
        doorlist = Entities:FindAllByClassnameWithin("prop_door_rotating_physics",soldier:GetAbsOrigin(),1024)
        DOORCLOSEST()
        DoorCheckOpen()
        if door ~= nil and dooropen ~= true then
                print(door:GetName())
                DoorRadiusChecker()
                
        end
    return 2

    else
        thisEntity:StopThink("DoorThinker")
    end
end

function DOORCLOSEST()
    if doorlist ~= nil then
        LISTOFDIST = {}
        for key,val in pairs(doorlist) do 
            DISTAWAY = (soldier:GetAbsOrigin() - val:GetAbsOrigin()):Length()
            table.insert(LISTOFDIST,key,DISTAWAY)   -- for each entity insert the distance away you are and the key that is associated with that distance
        end
        --print(unpack(LISTOFDIST))
        local t = LISTOFDIST
        local sorted = {}
        for k,v in pairs(t) do
            table.insert(sorted,{k,v})
        end
        table.sort(sorted,function(a,b) return a[2]>b[2] end)
        for _,v in ipairs(sorted) do
            uni = tonumber(v[1])
        end
        UNICHECKER()
        door = doorlist[uni]
        
    end
end 
    


function UNICHECKER()
    
    if i == 1 then
    curval = uni
    i = i + 1
    end
    if curval ~= uni then 
        print("VAL CHANGED")
    i = 1
    

    end
end


function DoorRadiusChecker()
    present = Entities:FindByClassnameWithin(nil,"npc_combine_s",door:GetAbsOrigin(),150)
    if present ~= nil then
        --print("Soldier is in Radius of Door")
        flDisttoNPC = (soldier:GetAbsOrigin() - door:GetAbsOrigin()):Length()
        if flDisttoNPC < 65 and dooropen == false then 
            --print(flDisttoNPC)
            soldier:NpcNavClearGoal()
            CheckBreach()

        else     
            MoveToDoor()
        end
    end
end 

function MoveToDoor()
    flNavGoalTolerance = 5
    flMinNpcDist = 35

    vVecToTargetNorm =(soldier:GetOrigin() - door:GetAbsOrigin() ):Normalized()
    vGoalPos = soldier:GetAbsOrigin() - (vVecToTargetNorm * flMinNpcDist);
    vCurrentGoalPos = thisEntity:NpcNavGetGoalPosition()
    flDistNPCTOGOAL = ( door:GetAbsOrigin() - vCurrentGoalPos ):Length()
    flTimeSincePath = Time() - flLastPathTime

    if door ~= nil and soldier ~= nil and flDisttoNPC > 40 then
        if ( flDistNPCTOGOAL > flMinNpcDist ) and ( flTimeSincePath > flRepathTime ) then
            CreatePathToGoal(door)
            print("going")
        end
    end
end
            

function DoorSwing()
    if door ~= nil then
    dooropen = true
    soldier:SetGraphParameterBool("b_kick_obstruction",false)
        door:SetThink(function() return KickEnder(door) end, "KickEnder", 1)
        function KickEnder()
            EntFireByHandle(thisEntity,door, "setspeed", "100")
            return nil
        end
       
    end
end


function CheckBreach()
if dooropen == false then
        local choice = math.random(1,2)
            if choice == 1 then 
            doorhandle = door:ScriptLookupAttachment("handle")
            soldier:SetGraphLookTarget(door:GetAttachmentOrigin(doorhandle))

            ShootDoorOpen()
        elseif choice == 2 then
            DoorKicker()
        end
    end
end
    


function ShootDoorOpen()
    doorhandle = door:ScriptLookupAttachment("handle")
    soldier:SetGraphLookTarget(door:GetAttachmentOrigin(doorhandle))
    EntFireByHandle(thisEntity,thisEntity,"SetForceAim","1")
    dooropen = true
    soldier:SetGraphParameterBool("b_firing", true)
    soldier:SetThink(function() return ShootEnder(soldier) end, "firing", 1.5)
    soldier:EmitSound("vo.combine.grunt.announceattack_grenade_09")
    function ShootEnder()
        
        EntFireByHandle(thisEntity,door, "setspeed", "1000")
        EntFireByHandle(thisEntity,door, "openawayfrom", "breacher")
        

        DoorSwing()
        return nil
    end
end


function DoorKicker()  
    soldier:SetGraphLookTarget(door:GetAbsOrigin() + Vector (0,0,65))
    soldier:SetGraphParameterBool("b_kick_obstruction", true)

    dooropen = true
    soldier:EmitSound("vo.combine.grunt.announceattack_grenade_09")
    soldier:SetThink(function() return KickEnder(soldier) end, "kick_obstruction", 1)
    function KickEnder()
        EntFireByHandle(thisEntity,door, "setspeed", "1000")
        EntFireByHandle(thisEntity,door, "openawayfrom", "breacher")

        DoorSwing()
        return nil
    end       
end





    
function CreatePathToGoal( GOAL ) 

	-- Find the vector from this entity to the player
	local vVecTotargetNorm = ( GOAL:GetAbsOrigin() - thisEntity:GetAbsOrigin() ):Normalized()

	-- Then find the point along that vector that is flMinPlayerDist from the player
	local vGoalPos = GOAL:GetAbsOrigin() - ( vVecTotargetNorm * flMinNpcDist );

	-- Create a path to that goal.  This will replace any existing path
	-- The path gets sent to the AnimGraph, and its up to the graph to make the character
	-- walk along the path
	thisEntity:NpcForceGoPosition( vGoalPos, true , flNavGoalTolerance )

	flLastPathTime = Time()
end



function AngleCheck()
    if door ~= nil then
        local defaultanglesy = math.floor(door:GetLocalAngles().y)
    print( defaultanglesy, "LOCAL ANGLES")

    end
end






function DoorCheckOpen()
    if i == 1 then
        if door ~= nil then
            local doorForwardDirection = (math.floor(door:GetAngles().y))
            originalposition = {}
            table.insert(originalposition, uni, doorForwardDirection)
            
            print(unpack(originalposition),"THIS IS ORIGINAL POS")
        end
    else
        local currentPosition = (math.floor(door:GetAngles().y))
        local AngleDifference = AngleDiff(originalposition[uni], currentPosition)
                print(AngleDifference)
        if AngleDifference == 90 or AngleDifference == -90  then 
            table.insert(DOORSTATUSTABLE, uni, OPEN)
            dooropen = true
            print(unpack(DOORSTATUSTABLE))
            print(dooropen)
        else
            dooropen = false
            table.insert(DOORSTATUSTABLE, uni, CLOSED)
            print(unpack(DOORSTATUSTABLE))
            print(dooropen)
        end 
        
        
    
    end
end

