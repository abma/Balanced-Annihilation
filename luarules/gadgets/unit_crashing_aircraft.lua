   function gadget:GetInfo()
      return {
        name      = "Crashing Aircraft",
        desc      = "Make aircraft crash-land instead of exploding",
        author    = "Beherith",
        date      = "aug 2012",
        license   = "PD",
        layer     = 1000,
        enabled   = true,
      }
    end
     
if (not gadgetHandler:IsSyncedCode()) then
  return
end

local random			= math.random 
local GetUnitHealth 	= Spring.GetUnitHealth
local SetUnitCOBValue 	= Spring.SetUnitCOBValue
local SetUnitNoSelect	= Spring.SetUnitNoSelect
local SetUnitSensorRadius = Spring.SetUnitSensorRadius

local COB_CRASHING = COB.CRASHING
local COM_BLAST = WeaponDefNames['commander_blast'].id 

local crashable  = {}
local crashing = {}

function gadget:Initialize()
	--set up table to check against
	for _,UnitDef in pairs(UnitDefs) do
		if UnitDef.canFly == true and not UnitDef.transportSize then
			crashable[UnitDef.id] = true
		end
	end
	crashable[UnitDefNames['armcybr'].id] = false -- remove atomic bomber from crashables because it can shoot during ceashing
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponDefID, projectileID, attackerID, attackerDefID, attackerTeam)
	if paralyzer then return damage,1 end 
	if crashing[unitID] then 
		return 0,0
	end 

	if crashable[unitDefID] and (damage>GetUnitHealth(unitID)) and random()<0.5 and weaponDefID ~= COM_BLAST then

		-- make it crash
		crashing[unitID] = true
		SetUnitCOBValue(unitID, COB_CRASHING, 1)
		SetUnitNoSelect(unitID,true)

        -- remove sensors
        SetUnitSensorRadius(unitID, "los", 0)
        SetUnitSensorRadius(unitID, "airLos", 0)
        SetUnitSensorRadius(unitID, "radar", 0)
        SetUnitSensorRadius(unitID, "sonar", 0)
--        SetUnitSensorRadius(unitID, "seismic", 0)
--        SetUnitSensorRadius(unitID, "radarJammer", 0)
--        SetUnitSensorRadius(unitID, "sonarJammer", 0)
	end
	return damage,1
end

function gadget:UnitDestroyed(unitID, unitDefID, teamID, attackerID, attackerDefID, attackerTeamID)
	if crashing[unitID] then
		crashing[unitID]=nil
	end
end