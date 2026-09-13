---@meta

---@class soundlib.SoundObjectBase : via.clr.ManagedObject
---@class soundlib.SoundBehaviorBase : via.Behavior
---@class soundlib.SoundContainableUserData : soundlib.SoundUserDataBase
---@class soundlib.SoundUserDataBase : via.sound.SoundUserData

---@class soundlib.SoundManager.RequestInfo : soundlib.SoundTriggerInfo
---@field get_SrcGameObj fun(self: soundlib.SoundManager.RequestInfo): via.GameObject

---@class soundlib.SoundTriggerInfo : soundlib.SoundObjectBase
---@field get_EventId fun(self: soundlib.SoundTriggerInfo): System.UInt32
---@field get_TriggerId fun(self: soundlib.SoundTriggerInfo): System.UInt32
---@field get_Valid fun(self: soundlib.SoundTriggerInfo): System.Boolean

---@class soundlib.SoundContainer : soundlib.SoundBehaviorBase
---@field get_AllTriggerInfoListData fun(self: soundlib.SoundContainer): System.Array<soundlib.SoundTriggerInfoListData>

---@class soundlib.SoundTriggerInfoListData : soundlib.SoundContainableUserData
---@field get_Bank fun(self: soundlib.SoundTriggerInfoListData): via.simplewwise.BankResourceHolder
---@field get_TriggerInfoList fun(self: soundlib.SoundTriggerInfoListData): System.Array<soundlib.SoundTriggerInfo>
