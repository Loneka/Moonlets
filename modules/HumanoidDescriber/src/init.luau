local MarketplaceService = game:GetService("MarketplaceService")

local Signal = require(script.Parent.Signal)
local DeepCopy = require(script.Parent.DeepCopy)
local AvatarAssetTypes = require(script.AvatarAssetTypes)
local AssetAccessoryTypes = require(script.AssetAccessoryTypes)
local Future = require(script.Parent.Future)

export type CatalogItem = {
	AssetId: number,
	Name: string,
	Type: string,
	AssetType: string,
}
export type AccessorySpec = {
	AssetId: number,
	AccessoryType: Enum.AccessoryType,
	Order: number?,
	Puffiness: number?,
	IsLayered: boolean?,
	Position: Vector3?,
	Rotation: Vector3?,
	Scale: Vector3?,
}
export type EquippedEmote = {
	Name: string,
	Slot: number,
}
export type Data = {
	Accessories: { AccessorySpec },
	Emotes: {
		[string]: { number },
	},
	EquippedEmotes: { EquippedEmote },
	Face: number,
	Scale: {
		BodyType: number,
		Depth: number,
		Head: number,
		Height: number,
		Proportion: number,
		Width: number,
	},
	Animations: {
		Walk: number,
		Run: number,
		Fall: number,
		Climb: number,
		Swim: number,
		Idle: number,
		Mood: number,
		Jump: number,
	},
	BodyParts: {
		Head: number,
		Torso: number,
		LeftArm: number,
		RightArm: number,
		LeftLeg: number,
		RightLeg: number,
	},
	BodyPartColors: {
		Head: Color3,
		Torso: Color3,
		LeftArm: Color3,
		RightArm: Color3,
		LeftLeg: Color3,
		RightLeg: Color3,
	},
	Clothing: {
		Shirt: number,
		TShirt: number,
		Pants: number,
	},
}

local function Extract(Source: { [any]: any }, Callback: (any, any) -> any)
	local Extracted = {}

	for Key, Value in pairs(Source) do
		table.insert(Extracted, Callback(Key, Value))
	end

	return Extracted
end
local function UnpackInto(Target: { [number]: any }, Source: { [number]: any })
	for _, Entry in ipairs(Source) do
		table.insert(Target, Entry)
	end
end

local function New(HumanoidDescription: HumanoidDescription)
	local HumanoidDescriber: HumanoidDescriber = {
		Data = {
			Accessories = {},
			Emotes = {},
			Face = 0,
			Scale = {
				BodyType = 0,
				Depth = 0,
				Head = 0,
				Height = 0,
				Proportion = 0,
				Width = 0,
			},
			Animations = {
				Walk = 0,
				Run = 0,
				Fall = 0,
				Climb = 0,
				Swim = 0,
				Idle = 0,
				Mood = 0,
				Jump = 0,
			},
			BodyParts = {
				Head = 0,
				Torso = 0,
				LeftArm = 0,
				RightArm = 0,
				LeftLeg = 0,
				RightLeg = 0,
			},
			BodyPartColors = {
				Head = Color3.fromRGB(0, 0, 0),
				Torso = Color3.fromRGB(0, 0, 0),
				LeftArm = Color3.fromRGB(0, 0, 0),
				RightArm = Color3.fromRGB(0, 0, 0),
				LeftLeg = Color3.fromRGB(0, 0, 0),
				RightLeg = Color3.fromRGB(0, 0, 0),
			},
			Clothing = {
				Shirt = 0,
				TShirt = 0,
				Pants = 0,
			},
		},
		HumanoidDescription = Instance.new("HumanoidDescription"),
		Updated = Signal.new(),
	}

	function HumanoidDescriber:EquipAsset(AssetId: number, AssetType: Enum.AvatarAssetType)
		if not self:IsAssetEquipped(AssetId, AssetType) then
			self:SetAssetEquipped(AssetId, AssetType, true)
		end
	end

	function HumanoidDescriber:UnequipAsset(AssetId: number, AssetType: Enum.AvatarAssetType)
		if self:IsAssetEquipped(AssetId, AssetType) then
			self:SetAssetEquipped(AssetId, AssetType, false)
		end
	end

	function HumanoidDescriber:SetAssetEquipped(AssetId: number, AssetType: Enum.AvatarAssetType, Equip: boolean)
		local Equipped = self:IsAssetEquipped(AssetId, AssetType)

		if table.find(AvatarAssetTypes.Types.Accessories, AssetType) then
			local AccessoryType = AssetAccessoryTypes[AssetType]
			if AccessoryType then
				if Equip then
					if not Equipped then
						self:AddAccessory({
							AssetId = AssetId,
							AccessoryType = AccessoryType,
							Order = 1,
						})
					end
				else
					self:RemoveAccessory(AssetId)
				end
			end
		elseif AssetType == Enum.AvatarAssetType.Face then
			self:UpdateData(function(Data)
				if Equip then
					if not Equipped then
						Data.Face = AssetId
					end
				else
					Data.Face = 0
				end

				return Data
			end)
		elseif table.find(AvatarAssetTypes.Types.Clothing, AssetType) then
			self:UpdateData(function(Data)
				if Equip then
					if not Equipped then
						Data.Clothing[AssetType.Name] = AssetId
					end
				else
					Data.Clothing[AssetType.Name] = 0
				end

				return Data
			end)
		elseif AssetType == Enum.AvatarAssetType.EmoteAnimation then
			local Name, Emote = self:GetEmoteByAssetId(AssetId)

			if Name == nil then
				Future.Try(function()
					local ProductInfo = MarketplaceService:GetProductInfo(AssetId, Enum.InfoType.Asset)
					if ProductInfo then
						Name = ProductInfo.Name
						Emote = { ProductInfo.AssetId }

						self:SetEmote(Name, Emote)
					end
				end):Await()
			end

			self:SetEmoteEquipped(Name, not Equipped)
		elseif table.find(AvatarAssetTypes.Types.Animations, AssetType) then
			self:UpdateData(function(Data)
				local AnimationName = string.gsub(AssetType.Name, "Animation", "", 1)
				local Animation = Data.Animations[AnimationName]
				if Animation then
					if Equip then
						if not Equipped then
							Data.Animations[AnimationName] = AssetId
						end
					else
						Data.Animations[AnimationName] = 0
					end
				end

				return Data
			end)
		elseif table.find(AvatarAssetTypes.Types.BodyParts, AssetType) then
			self:UpdateData(function(Data)
				local PartName = AssetType.Name
				if PartName == "DynamicHead" then
					PartName = "Head"
				end

				local BodyPart = Data.BodyParts[PartName]
				if BodyPart then
					if Equip then
						if not Equipped then
							Data.BodyParts[PartName] = AssetId
						end
					else
						Data.BodyParts[PartName] = 0
					end
				end

				return Data
			end)
		end
	end

	function HumanoidDescriber:IsAssetEquipped(AssetId: number, AssetType: Enum.AvatarAssetType)
		local Data = self:GetData()

		if table.find(AvatarAssetTypes.Types.Accessories, AssetType) then
			return self:GetAccessory(AssetId) ~= nil
		elseif AssetType == Enum.AvatarAssetType.Face then
			return Data.Face == AssetId
		elseif table.find(AvatarAssetTypes.Types.Clothing, AssetType) then
			return Data.Clothing[AssetType.Name] == AssetId
		elseif AssetType == Enum.AvatarAssetType.EmoteAnimation then
			local Name = self:GetEmoteByAssetId(AssetId)
			return self:GetEquippedEmote(Name) ~= nil
		elseif table.find(AvatarAssetTypes.Types.Animations, AssetType) then
			local AnimationName = string.gsub(AssetType.Name, "Animation", "", 1)
			local Animation = Data.Animations[AnimationName]

			return Animation == AssetId
		elseif table.find(AvatarAssetTypes.Types.BodyParts, AssetType) then
			local PartName = AssetType.Name
			if PartName == "DynamicHead" then
				PartName = "Head"
			end

			local BodyPart = Data.BodyParts[PartName]

			return BodyPart == AssetId
		else
			return false
		end
	end

	function HumanoidDescriber:SetEmoteEquipped(Name: string, Equip: boolean, Slot: number?)
		local Data = self:GetData()

		if Slot == nil then
			if Equip then
				local PotentialSlots = {}

				for Count = 1, 8 do
					table.insert(PotentialSlots, Count)
				end

				for _, Emote in ipairs(Data.EquippedEmotes) do
					local PotentialSlotIndex = table.find(PotentialSlots, Emote.Slot)
					if PotentialSlotIndex then
						table.remove(PotentialSlots, PotentialSlotIndex)
					end
				end

				Slot = PotentialSlots[1] or 8
			else
				local _, Emote = self:GetEquippedEmote(Name)
				if Emote then
					Slot = Emote.Slot
				else
					Slot = 8
				end
			end
		end

		self:UpdateData(function(ModifierData)
			local ExistingIndex = self:GetEquippedEmoteBySlot(Slot)

			if ExistingIndex then
				table.remove(ModifierData.EquippedEmotes, ExistingIndex)
			end

			if Equip then
				table.insert(ModifierData.EquippedEmotes, {
					Name = Name,
					Slot = Slot,
				})
			end

			return ModifierData
		end)
	end

	function HumanoidDescriber:GetEquippedEmoteBySlot(Slot: number)
		local Data = self:GetData()

		for Index, Emote in ipairs(Data.EquippedEmotes) do
			if Emote.Slot == Slot then
				return Index, Emote
			end
		end

		return nil
	end

	function HumanoidDescriber:GetEquippedEmote(Name: string): (number?, EquippedEmote?)
		local Data = self:GetData()

		for Index, Emote in ipairs(Data.EquippedEmotes) do
			if Emote.Name == Name then
				return Index, Emote
			end
		end

		return nil
	end

	function HumanoidDescriber:SetEmote(Name: string, Emote: { number } | nil)
		self:UpdateData(function(Data)
			Data.Emotes[Name] = Emote
			return Data
		end)
	end

	function HumanoidDescriber:GetEmoteByAssetId(AssetId: number)
		local Data = self:GetData()

		for Name, Emote in pairs(Data.Emotes) do
			if table.find(Emote, AssetId) ~= nil then
				return Name, Emote
			end
		end

		return nil
	end

	function HumanoidDescriber:GetEmote(Name: string)
		local Data = self:GetData()

		for EmoteName, Emote in pairs(Data.Emotes) do
			if EmoteName == Name then
				return Emote
			end
		end

		return nil
	end

	function HumanoidDescriber:ToggleAccessory(Accessory: AccessorySpec)
		if self:GetAccessory(Accessory.AssetId) then
			self:RemoveAccessory(Accessory.AssetId)
		else
			self:AddAccessory(Accessory)
		end
	end

	function HumanoidDescriber:AddAccessory(Accessory: AccessorySpec)
		local AccessoryIndex = self:GetAccessory(Accessory.AssetId)

		if AccessoryIndex == nil then
			self:UpdateData(function(Data)
				table.insert(Data.Accessories, Accessory)
				return Data
			end)
		end
	end

	function HumanoidDescriber:RemoveAccessory(AssetId: number)
		local AccessoryIndex = self:GetAccessory(AssetId)

		if AccessoryIndex ~= nil then
			self:UpdateData(function(Data)
				table.remove(Data.Accessories, AccessoryIndex)
				return Data
			end)
		end
	end

	function HumanoidDescriber:GetAccessory(AssetId: number): (number?, AccessorySpec?)
		local Data = self:GetData()

		for Index, Accessory: AccessorySpec in ipairs(Data.Accessories) do
			if Accessory.AssetId == AssetId then
				return Index, Accessory
			end
		end

		return nil
	end

	function HumanoidDescriber:GetAssets(IgnoreBundleAssets: boolean?): { number }
		local Data: Data = self:GetData()

		local AssetIds = {
			Data.Face,
		}

		UnpackInto(
			AssetIds,
			Extract(Data.Accessories, function(_, Value)
				return Value.AssetId
			end)
		)
		UnpackInto(
			AssetIds,
			Extract(Data.Emotes, function(_, Value)
				return table.unpack(Value)
			end)
		)
		UnpackInto(
			AssetIds,
			Extract(Data.Clothing, function(_, AssetId)
				return AssetId
			end)
		)

		if not IgnoreBundleAssets then
			UnpackInto(
				AssetIds,
				Extract(Data.Animations, function(_, Value)
					return Value
				end)
			)
			UnpackInto(
				AssetIds,
				Extract(Data.BodyParts, function(_, Value)
					return Value
				end)
			)
		end

		local InvalidAssetIds = {}
		for Key, AssetId in ipairs(AssetIds) do
			if (AssetId == nil) or (AssetId == 0) or (table.find(AssetIds, AssetId, Key + 1) ~= nil) then
				table.insert(InvalidAssetIds, AssetId)
			end
		end

		for _, AssetId in ipairs(InvalidAssetIds) do
			local Index = table.find(AssetIds, AssetId)
			if Index ~= nil then
				table.remove(AssetIds, Index)
			end
		end

		return AssetIds
	end

	function HumanoidDescriber:ReadFromDescription(NewHumanoidDescription: HumanoidDescription)
		self.HumanoidDescription = NewHumanoidDescription

		local NewData: Data = {
			Face = self.HumanoidDescription.Face,
			Accessories = self.HumanoidDescription:GetAccessories(true),
			Emotes = self.HumanoidDescription:GetEmotes(),
			EquippedEmotes = self.HumanoidDescription:GetEquippedEmotes(),
			Scale = {
				BodyType = self.HumanoidDescription.BodyTypeScale,
				Depth = self.HumanoidDescription.DepthScale,
				Head = self.HumanoidDescription.HeadScale,
				Height = self.HumanoidDescription.HeightScale,
				Proportion = self.HumanoidDescription.ProportionScale,
				Width = self.HumanoidDescription.WidthScale,
			},
			BodyParts = {
				Head = self.HumanoidDescription.Head,
				Torso = self.HumanoidDescription.Torso,
				LeftLeg = self.HumanoidDescription.LeftLeg,
				RightLeg = self.HumanoidDescription.RightLeg,
				LeftArm = self.HumanoidDescription.LeftArm,
				RightArm = self.HumanoidDescription.RightArm,
			},
			Animations = {
				Idle = self.HumanoidDescription.IdleAnimation,
				Walk = self.HumanoidDescription.WalkAnimation,
				Run = self.HumanoidDescription.RunAnimation,
				Fall = self.HumanoidDescription.FallAnimation,
				Jump = self.HumanoidDescription.JumpAnimation,
				Mood = self.HumanoidDescription.MoodAnimation,
				Swim = self.HumanoidDescription.SwimAnimation,
				Climb = self.HumanoidDescription.ClimbAnimation,
			},
			Clothing = {
				Shirt = self.HumanoidDescription.Shirt,
				TShirt = self.HumanoidDescription.GraphicTShirt,
				Pants = self.HumanoidDescription.Pants,
			},
			BodyPartColors = {
				Head = self.HumanoidDescription.HeadColor,
				Torso = self.HumanoidDescription.TorsoColor,
				LeftLeg = self.HumanoidDescription.LeftLegColor,
				RightLeg = self.HumanoidDescription.RightLegColor,
				LeftArm = self.HumanoidDescription.LeftArmColor,
				RightArm = self.HumanoidDescription.RightArmColor,
			},
		}

		self:UpdateData(function()
			return NewData
		end, false)
	end

	function HumanoidDescriber:_UpdateHumanoidDescription()
		local Data = self:GetData()
		local Properties = {
			Face = Data.Face,

			BodyTypeScale = Data.Scale.BodyType,
			DepthScale = Data.Scale.Depth,
			HeadScale = Data.Scale.Head,
			HeightScale = Data.Scale.Height,
			ProportionScale = Data.Scale.Proportion,
			WidthScale = Data.Scale.Width,

			WalkAnimation = Data.Animations.Walk,
			RunAnimation = Data.Animations.Run,
			FallAnimation = Data.Animations.Fall,
			ClimbAnimation = Data.Animations.Climb,
			SwimAnimation = Data.Animations.Swim,
			IdleAnimation = Data.Animations.Idle,
			MoodAnimation = Data.Animations.Mood,
			JumpAnimation = Data.Animations.Jump,

			Head = Data.BodyParts.Head,
			Torso = Data.BodyParts.Torso,
			LeftArm = Data.BodyParts.LeftArm,
			RightArm = Data.BodyParts.RightArm,
			LeftLeg = Data.BodyParts.LeftLeg,
			RightLeg = Data.BodyParts.RightLeg,

			HeadColor = Data.BodyPartColors.Head,
			TorsoColor = Data.BodyPartColors.Torso,
			LeftArmColor = Data.BodyPartColors.LeftArm,
			RightArmColor = Data.BodyPartColors.RightArm,
			LeftLegColor = Data.BodyPartColors.LeftLeg,
			RightLegColor = Data.BodyPartColors.RightLeg,

			Shirt = Data.Clothing.Shirt,
			GraphicTShirt = Data.Clothing.TShirt,
			Pants = Data.Clothing.Pants,
		}

		for Name, Value in pairs(Properties) do
			if self.HumanoidDescription[Name] ~= Value then
				self.HumanoidDescription[Name] = Value
			end
		end

		self.HumanoidDescription:SetAccessories(Data.Accessories, true)
		self.HumanoidDescription:SetEmotes(Data.Emotes)
		self.HumanoidDescription:SetEquippedEmotes(Data.EquippedEmotes)
	end

	function HumanoidDescriber:UpdateData(ModifierCallback: (Data) -> Data, UpdateDescription: boolean?)
		if UpdateDescription == nil then
			UpdateDescription = true
		end

		local OldData = self:GetData()
		local NewData = ModifierCallback(self:GetData())

		if NewData ~= nil then
			self.Data = NewData

			if UpdateDescription then
				self:_UpdateHumanoidDescription()
			end

			self.Updated:Fire(OldData, NewData)
		else
			assert(false, "Data was not returned.")
		end
	end

	function HumanoidDescriber:GetData(): Data
		return DeepCopy(self.Data)
	end

	function HumanoidDescriber:Destroy()
		self.Updated:Destroy()
	end

	HumanoidDescriber:ReadFromDescription(HumanoidDescription)

	return HumanoidDescriber
end

export type HumanoidDescriber = typeof(New(Instance.new("HumanoidDescription")))

return New
