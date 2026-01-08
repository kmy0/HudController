---@meta

---@class System.Object : via.clr.ManagedObject
---@class System.Reflection.MemberInfo : via.clr.ManagedObject
---@class System.ValueType : ValueType, via.clr.ManagedObject
---@class System.UInt32 : integer, System.ValueType
---@class System.Int32 : integer, System.ValueType
---@class System.Int16 : integer, System.ValueType
---@class System.UInt16 : integer, System.ValueType
---@class System.Byte : integer, System.ValueType
---@class System.Boolean : boolean, System.ValueType
---@class System.Char : System.ValueType
---@class System.Enum : integer, System.ValueType
---@class System.Single : number, System.ValueType
---@class System.Type : System.Reflection.MemberInfo
---@class System.Double : number, System.ValueType

---@class System.String : string, via.clr.ManagedObject
---@field ToString fun(self: System.String): System.String
---@field _stringLength System.Int32
---@field _firstChar System.Char

---@class System.Guid : System.ValueType
---@field mData1 System.UInt32
---@field mData2 System.UInt16
---@field mData3 System.UInt16
---@field mData4_0 System.Byte
---@field mData4_1 System.Byte
---@field mData4_2 System.Byte
---@field mData4_3 System.Byte
---@field mData4_4 System.Byte
---@field mData4_5 System.Byte
---@field mData4_6 System.Byte
---@field mData4_7 System.Byte
---@field Parse fun(self: System.Guid, guid_string: string): System.Guid

---@class System.Nullable<T> : System.ValueType
---@field _Value any
---@field _HasValue System.Boolean

---@class System.ArrayEnumerator<T> : via.clr.ManagedObject
---@field MoveNext fun(self: System.ArrayEnumerator): System.Boolean
---@field get_Current fun(self: System.ArrayEnumerator): any

---@class System.Array<T> : {[integer]: T},System.Object
---@field get_Count fun(self: System.Array<any>): integer
---@field get_Item fun(self: System.Array<any>, i: integer): any
---@field set_Item fun(self: System.Array<any>, i: integer, item: any)
---@field Contains fun(self: System.Array<any>, item: any): System.Boolean
---@field ToArray fun(self: System.Array<any>): System.Array<any>
---@field GetEnumerator fun(self: System.Array<any>): System.ArrayEnumerator<any>
---@field IndexOf fun(self: System.Array<any>, item: any): System.Int32
---@field AddRange fun(self: System.Array<any>, list: System.Array<any>)
---@field AddWithResize fun(self: System.Array<any>, item: any)
---@field Remove fun(self: System.Array<any>, item: any): System.Boolean
---@field Clear fun(self: System.Array<any>)

---@class System.Collections.BitArray : via.clr.ManagedObject
---@field get_Item fun(self: System.Collections.BitArray, index: System.Int32): System.Boolean
---@field set_Item fun(self: System.Collections.BitArray, index: System.Int32, val: System.Boolean)
