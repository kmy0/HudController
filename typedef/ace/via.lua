---@meta

---@class via.clr.ManagedObject : via.Object
---@class via.Object : REManagedObject
---@class via.UserData : via.clr.ManagedObject
---@class via.vec3 : Vector3f
---@class via.gui.Window : via.gui.Control
---@class via.gui.View : via.gui.Window
---@class via.gui.Panel : via.gui.Capture
---@class via.gui.Capture : via.gui.Control
---@class via.gui.Element : via.gui.PlayObject
---@class via.gui.DrawableElement : via.gui.PlayObject
---@class via.gui.MaskableElement : via.gui.DrawableElement

---@class via.Size
---@field w System.Single
---@field h System.Single

---@class via.Float4
---@field x System.Single
---@field y System.Single
---@field z System.Single
---@field w System.Single

---@class via.Point
---@field x System.Single
---@field y System.Single

---@class via.Int2
---@field x System.Int32
---@field y System.Int32

---@class via.Color
---@field rgba System.UInt32

---@class via.Component : via.clr.ManagedObject
---@field get_GameObject fun(self: via.Component): via.GameObject
---@field ToString fun(self: via.Component): System.String

---@class via.Behavior : via.Component
---@field get_Started fun(self: via.Behavior): System.Boolean
---@field get_Valid fun(self: via.Behavior): System.Boolean

---@class via.Scene : via.clr.ManagedObject
---@field get_FrameCount fun(self: via.Scene): System.UInt32

---@class via.SceneView : via.gui.TransformObject
---@field get_WindowSize fun(self: via.SceneView): via.Size

---@class via.gui.GUISystem : NativeSingleton
---@field get_MessageLanguage fun(self: via.gui.GUISystem): via.Language

---@class via.SceneManager : NativeSingleton
---@field get_MainView fun(self: via.SceneManager): via.SceneView
---@field get_CurrentScene fun(self: via.SceneManager): via.Scene

---@class via.Application : NativeSingleton
---@field get_DeltaTime fun(self: via.Application): System.Single

---@class via.GameObject : via.clr.ManagedObject
---@field get_Name fun(self: via.GameObject): System.String
---@field get_Transform fun(self: via.GameObject): via.Transform

---@class via.Transform : via.Component
---@field get_GameObject fun(self: via.Transform): via.GameObject
---@field get_Parent fun(self: via.Transform): via.Transform?
---@field get_Position fun(self: via.Transform): via.vec3

---@class via.gui.GUI : via.Component
---@field get_Enabled fun(self: via.gui.GUI): System.Boolean
---@field get_View fun(self: via.gui.GUI): via.gui.View

---@class via.gui.Control : via.gui.TransformObject
---@field get_Segment fun(self: via.gui.Control): via.gui.Segment
---@field set_Segment fun(self: via.gui.Control, segment: via.gui.Segment)
---@field get_ColorScale fun(self: via.gui.Control): via.Float4
---@field set_ColorScale fun(self: via.gui.Control, color: via.Float4)
---@field getChildren fun(self: via.gui.Control, type: System.Type): System.Array<System.Type>
---@field set_PlayState fun(self: via.gui.Control, state: System.String)
---@field get_PlayState fun(self: via.gui.Control): System.String
---@field get_PlayStateNames fun(self: via.gui.Control): via.gui.Control.WrappedArrayContainer_PlayStateNames
---@field hitTest fun(self: via.gui.Control, point: via.Point): System.Boolean

---@class via.gui.Control.WrappedArrayContainer_PlayStateNames : via.clr.ManagedObject
---@field get_Count fun(self: via.gui.Control.WrappedArrayContainer_PlayStateNames): System.Int32
---@field get_Item fun(self: via.gui.Control.WrappedArrayContainer_PlayStateNames, index: System.Int32): System.String

---@class via.gui.TransformObject : via.gui.PlayObject
---@field set_Rotation fun(self: via.gui.TransformObject, rot: Vector3f)
---@field get_Rotation fun(self: via.gui.TransformObject): via.vec3
---@field set_Position fun(self: via.gui.TransformObject, offset: Vector3f)
---@field get_Position fun(self: via.gui.TransformObject): via.vec3
---@field set_Scale fun(self: via.gui.TransformObject, scale: Vector3f)
---@field get_Scale fun(self: via.gui.TransformObject): via.vec3
---@field get_GlobalPosition fun(self: via.gui.TransformObject): via.vec3
---@field get_Child fun(self: via.gui.TransformObject): via.gui.PlayObject

---@class via.gui.PlayObject : via.clr.ManagedObject
---@field set_Visible fun(self: via.gui.PlayObject, visible: System.Boolean)
---@field get_Parent fun(self: via.gui.PlayObject): via.gui.Control
---@field get_Name fun(self: via.gui.PlayObject): System.String
---@field get_Visible fun(self: via.gui.PlayObject): System.Boolean
---@field get_Component fun(self: via.gui.PlayObject): via.gui.GUI
---@field get_Next fun(self: via.gui.PlayObject): via.gui.PlayObject
---@field set_ForceInvisible fun(self: via.gui.PlayObject, is_invis: System.Boolean)
---@field get_ForceInvisible fun(self: via.gui.PlayObject): System.Boolean

---@class via.gui.SelectItem : via.gui.Control
---@field get_ListIndex fun(self: via.gui.SelectItem): System.Int32

---@class via.gui.Text : via.gui.MaskableElement
---@field set_Rotation fun(self: via.gui.Text, rot: Vector3f)
---@field get_Rotation fun(self: via.gui.Text): via.vec3
---@field set_Position fun(self: via.gui.Text, offset: Vector3f)
---@field get_Position fun(self: via.gui.Text): via.vec3
---@field get_GlobalPosition fun(self: via.gui.Text): via.vec3
---@field get_FontSize fun(self: via.gui.Text): via.Size
---@field set_FontSize fun(self: via.gui.Text, size: via.Size)
---@field set_AutoRegionFit fun(self: via.gui.Text, region: via.gui.RegionFitType)
---@field set_Message fun(self: via.gui.Text, txt: System.String)
---@field get_Color fun(self: via.gui.Text): via.Color
---@field set_Color fun(self: via.gui.Text, color: via.Color)

---@class via.gui.HitArea : via.gui.Element
---@field get_Size fun(self: via.gui.HitArea ): via.Size
---@field get_GlobalPosition fun(self: via.gui.HitArea ): via.vec3

---@class via.gui.Rect : via.gui.MaskableElement
---@field set_Rotation fun(self: via.gui.Rect, rot: Vector3f)
---@field get_Rotation fun(self: via.gui.Rect): via.vec3
---@field set_Position fun(self: via.gui.Rect, offset: Vector3f)
---@field get_Position fun(self: via.gui.Rect): via.vec3
---@field get_Size fun(self: via.gui.Rect): via.Size
---@field set_Size fun(self: via.gui.Rect, size: via.Size)
---@field get_Color fun(self: via.gui.Rect): via.Color
---@field set_Color fun(self: via.gui.Rect, color: via.Color)

---@class via.gui.Material : via.gui.MaskableElement
---@field set_Rotation fun(self: via.gui.Material, rot: Vector3f)
---@field get_Rotation fun(self: via.gui.Material): via.vec3
---@field set_Position fun(self: via.gui.Material, offset: Vector3f)
---@field get_Position fun(self: via.gui.Material): via.vec3
---@field set_VariableFloat0 fun(self: via.gui.Material, var: System.Single)
---@field get_VariableFloat0 fun(self: via.gui.Material): System.Single
---@field set_VariableFloat1 fun(self: via.gui.Material, var: System.Single)
---@field get_VariableFloat1 fun(self: via.gui.Material): System.Single
---@field set_VariableFloat2 fun(self: via.gui.Material, var: System.Single)
---@field get_VariableFloat2 fun(self: via.gui.Material): System.Single
---@field set_VariableFloat3 fun(self: via.gui.Material, var: System.Single)
---@field get_VariableFloat3 fun(self: via.gui.Material): System.Single
---@field set_VariableFloat4 fun(self: via.gui.Material, var: System.Single)
---@field get_VariableFloat4 fun(self: via.gui.Material): System.Single
---@field get_Size fun(self: via.gui.Material): via.Size
---@field set_Size fun(self: via.gui.Material, size: via.Size)
---@field get_Color fun(self: via.gui.Material): via.Color
---@field set_Color fun(self: via.gui.Material, color: via.Color)
---@field get_MaterialParamsCount fun(self: via.gui.Material): System.Int32

---@class via.gui.Scale9Grid : via.gui.MaskableElement
---@field set_Rotation fun(self: via.gui.Scale9Grid , rot: Vector3f)
---@field get_Rotation fun(self: via.gui.Scale9Grid): via.vec3
---@field set_Position fun(self: via.gui.Scale9Grid , offset: Vector3f)
---@field get_Position fun(self: via.gui.Scale9Grid): via.vec3
---@field get_Size fun(self: via.gui.Scale9Grid): via.Size
---@field set_Size fun(self: via.gui.Scale9Grid , size: via.Size)
---@field get_Color fun(self: via.gui.Scale9Grid): via.Color
---@field set_Color fun(self: via.gui.Scale9Grid, color: via.Color)
---@field get_BlendType fun(self: via.gui.Scale9Grid): via.gui.BlendType
---@field get_ControlPoint fun(self: via.gui.Scale9Grid): via.gui.ControlPoint
---@field get_IgnoreAlpha fun(self: via.gui.Scale9Grid): System.Boolean
---@field set_BlendType fun(self: via.gui.Scale9Grid, blend: via.gui.BlendType)
---@field set_ControlPoint fun(self: via.gui.Scale9Grid, control_point: via.gui.ControlPoint)
---@field set_IgnoreAlpha fun(self: via.gui.Scale9Grid, ignore_alpha: System.Boolean)
---@field set_AlphaChannelType fun(self: via.gui.Scale9Grid, type: via.gui.AlphaChannelType)
---@field get_AlphaChannelType fun(self: via.gui.Scale9Grid): via.gui.AlphaChannelType

---@class via.gui.TextureSet : via.gui.MaskableElement
---@field get_RegionSize fun(self: via.gui.TextureSet): via.Size
---@field set_Rotation fun(self: via.gui.TextureSet, rot: Vector3f)
---@field get_Rotation fun(self: via.gui.TextureSet): via.vec3
---@field set_Position fun(self: via.gui.TextureSet, offset: Vector3f)
---@field get_Position fun(self: via.gui.TextureSet): via.vec3
---@field get_Color fun(self: via.gui.TextureSet): via.Color
---@field set_Color fun(self: via.gui.TextureSet, color: via.Color)
