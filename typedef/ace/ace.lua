---@meta

---@class ace.GUIBaseCore : via.Behavior
---@class ace.GAElementBase : via.Behavior
---@class ace.GAElement<T> : ace.GAElementBase
---@class ace.cGUIPartsBase : via.clr.ManagedObject
---@class ace.minicomponent.cOrderedActionBase : ace.minicomponent.cMiniComponent
---@class ace.minicomponent.cMiniComponent : ace.cNonCycleTypeObject
---@class ace.BIT_FLAG8 : ace.BIT_FLAG
---@class ace.BIT_FLAG16 : ace.BIT_FLAG
---@class ace.BIT_FLAG64 : ace.BIT_FLAG
---@class ace.cLeakCheckObject : via.clr.ManagedObject
---@class ace.cNonCycleTypeObject : ace.cLeakCheckObject
---@class ace.cSaveDataParam : ace.cSaveDataBase
---@class ace.cSaveDataBase : via.clr.ManagedObject
---@class ace.cGUIParameterBase : via.clr.ManagedObject
---@class ace.cGUIInputCtrlBase : ace.cNonCycleTypeObject
---@class ace.cGUIFlowBase : ace.cStateBase
---@class ace.cStateBase : ace.cNonCycleTypeObject
---@class ace.cGUIFlowContextBase : via.clr.ManagedObject
---@class ace.DialogueManagerBase : ace.GAElement
---@class ace.GimmickBase : ace.GimmickBaseCore
---@class ace.GimmickBaseCore : via.Behavior
---@class ace.mcGimmickBase : ace.minicomponent.cUpdatableBase
---@class ace.minicomponent.cUpdatableBase : ace.minicomponent.cMiniComponent

---@class ace.GUIFade : via.Behavior
---@field setFadeAlpha fun(self: ace.GUIFade, alpha: System.Single)
---@field setFadeColor fun(self: ace.GUIFade, color: via.Color)
---@field setDrawSegment fun(self: ace.GUIFade, segment: via.gui.Segment)
---@field open fun(self: ace.GUIFade)
---@field close fun(self: ace.GUIFade)
---@field _Color via.Color
---@field _RootWindow via.gui.Window

---@class ace.GUIManagerBase : ace.GAElement
---@field get_LastInputDeviceIgnoreMouseMove fun(self: ace.GUIManagerBase): ace.GUIDef.INPUT_DEVICE

---@class ace.GUIBase : ace.GUIBaseCore
---@field get_ID fun(self: ace.GUIBase): app.GUIID.ID
---@field _RootWindow via.gui.Control
---@field _PartsList System.Array<ace.cGUIPartsBase>
---@field _InputCtrls System.Array<ace.cGUIInputCtrl>
---@field _GUI via.gui.GUI

---@class ace.cSafeContinueFlagGroup : via.clr.ManagedObject
---@field check fun(self: ace.cSafeContinueFlagGroup, flag: System.UInt32): System.Boolean
---@field on fun(self: ace.cSafeContinueFlagGroup, flag: System.UInt32)
---@field off fun(self: ace.cSafeContinueFlagGroup, flag: System.UInt32)
---@field _Groups System.Array<ace.cSafeContinueFlagGroup.GROUP>

---@class ace.cSafeContinueFlagGroup.GROUP : via.clr.ManagedObject
---@field _Flags ace.Bitset

---@class ace.cSafeContinueFlag : via.clr.ManagedObject
---@field check fun(self: ace.cSafeContinueFlag, flag: System.UInt32): System.Boolean
---@field on fun(self: ace.cSafeContinueFlag, flag: System.UInt32)
---@field off fun(self: ace.cSafeContinueFlag, flag: System.UInt32)
---@field _Flags ace.Bitset

---@class ace.Bitset : via.clr.ManagedObject
---@field getMaxElement fun(self: ace.Bitset): System.Int32

---@class ace.BIT_FLAG : System.ValueType
---@field getMaxElement fun(self: ace.BIT_FLAG): System.Int32
---@field on fun(self: ace.BIT_FLAG, flag: System.Int32)
---@field off fun(self: ace.BIT_FLAG, flag: System.Int32)
---@field _Value System.UInt32

---@class ace.cGUIParamState : ace.cGUIParameterBase
---@field getValue fun(self: ace.cGUIParamState): System.String

---@class ace.cGUIInputCtrl_FluentScrollGrid : ace.cGUIInputCtrl
---@field getIndexFromItemCore fun(self: ace.cGUIInputCtrl_FluentScrollGrid, sel: via.gui.SelectItem, out: via.Int2)
---@field requestSelectIndexCore fun(self: ace.cGUIInputCtrl_FluentScrollGrid, x: System.Int32, y: System.Int32)

---@class ace.cGUIInputCtrl : ace.cGUIInputCtrlBase
---@field get_Callback fun(self: ace.cGUIInputCtrl): ace.cGUIInputCtrl.CallbackParam
---@field setEnableCtrl fun(self: ace.cGUIInputCtrl, val: System.Boolean)
---@field INPUT_FLAG_UP_DOWN_CUSTOM System.UInt32
---@field INPUT_FLAG_UP_DOWN_KEY System.UInt32
---@field INPUT_FLAG_UP_DOWN_RS System.UInt32
---@field INPUT_FLAG_LEFT_RIGHT_RS System.UInt32
---@field INPUT_FLAG_UP_DOWN_RIGHT_KEY System.UInt32
---@field INPUT_FLAG_LEFT_RIGHT_RIGHT_KEY System.UInt32
---@field INPUT_FLAG_LEFT_RIGHT_KEY System.UInt32
---@field _InputBit ace.BIT_FLAG

---@class ace.cGUIInputCtrl.CallbackParam : ace.cNonCycleTypeObject
---@field _SlotBtns System.Array<app.GUIFunc.TYPE>

---@class ace.PadManager : ace.GAElement
---@field get_MainPad fun(self: ace.PadManager): ace.cPadInfo

---@class ace.cPadInfo : via.clr.ManagedObject
---@field get_KeyOn fun(self: ace.cPadInfo): ace.ACE_PAD_KEY.BITS

---@class ace.MouseKeyboardManager : ace.GAElement
---@field get_MainMouseKeyboard fun(self: ace.MouseKeyboardManager): ace.cMouseKeyboardInfo

---@class ace.cMouseKeyboardInfo : via.clr.ManagedObject
---@field isOn fun(self: ace.cMouseKeyboardInfo, key: ace.ACE_MKB_KEY.INDEX): System.Boolean
---@field get_MousePos fun(self: ace.cMouseKeyboardInfo): via.Point

---@class ace.ACTION_ID : System.ValueType
---@field _Category System.Int32
---@field _Index System.Int32
