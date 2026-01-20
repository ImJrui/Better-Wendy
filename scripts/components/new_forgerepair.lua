local config_ghostflowerhat = GetModConfigData("ghostflowerhat")
if not config_ghostflowerhat then return end

local ForgeRepair = require("components/forgerepair")
local _OnRepair = ForgeRepair.OnRepair

function ForgeRepair:OnRepair(target, doer)
	if target.prefab ~= "ghostflowerhat" then return _OnRepair(self, target, doer) end

	local success
	if target.components.armor ~= nil then
		if target.components.armor:IsDamaged() then
			local percent = math.min(target.components.armor:GetPercent() + 0.2, 1)
			target.components.armor:SetPercent(percent)
			success = true
		end
	elseif target.components.finiteuses ~= nil then
		if target.components.finiteuses:GetPercent() < 1 then
			target.components.finiteuses:SetPercent(1)
			success = true
		end
	elseif target.components.fueled ~= nil then
		if target.components.fueled:GetPercent() < 1 then
			target.components.fueled:SetPercent(1)
			success = true
		end
	end

	if success then
		if self.inst.components.finiteuses ~= nil then
			self.inst.components.finiteuses:Use(1)
		elseif self.inst.components.stackable ~= nil then
			self.inst.components.stackable:Get():Remove()
		else
			self.inst:Remove()
		end

		if self.onrepaired ~= nil then
			self.onrepaired(self.inst, target, doer)
		end
		return true
	end
end