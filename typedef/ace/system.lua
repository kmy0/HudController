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
---@class System.MulticastDelegate : System.Delegate
---@class System.Delegate : via.clr.ManagedObject

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
---@field _Value T?
---@field _HasValue System.Boolean

---@class System.ArrayEnumerator<T> : via.clr.ManagedObject
---@field MoveNext fun(self: System.ArrayEnumerator): System.Boolean
---@field get_Current fun(self: System.ArrayEnumerator): T

---@class System.Array<T> : {[integer]: T},System.Object
---@field get_Count fun(self: System.Array<T>): integer
---@field get_Item fun(self: System.Array<T>, i: integer): T
---@field set_Item fun(self: System.Array<T>, i: integer, item: T)
---@field Contains fun(self: System.Array<T>, item: T): System.Boolean
---@field ToArray fun(self: System.Array<T>): System.Array<T>
---@field GetEnumerator fun(self: System.Array<T>): System.ArrayEnumerator<T>
---@field IndexOf fun(self: System.Array<T>, item: T): System.Int32
---@field AddRange fun(self: System.Array<T>, list: System.Array<T>)
---@field AddWithResize fun(self: System.Array<T>, item: T)
---@field Remove fun(self: System.Array<T>, item: T): System.Boolean
---@field Clear fun(self: System.Array<T>)

---@class System.Collections.BitArray : via.clr.ManagedObject
---@field get_Item fun(self: System.Collections.BitArray, index: System.Int32): System.Boolean
---@field set_Item fun(self: System.Collections.BitArray, index: System.Int32, val: System.Boolean)

---@class System.Dictionary<K, V> : System.Object
---@field _entries System.Array<System.DictionaryEntry<K, V>>

---@class System.DictionaryEntry<K, V>
---@field value V
