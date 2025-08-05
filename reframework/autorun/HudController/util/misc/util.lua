local this = {}

---@param rgba {r:integer, g:integer, b:integer, a:integer}
function this.rgba_to_int(rgba)
    return ((rgba.r & 0xFF) << 24) | ((rgba.g & 0xFF) << 16) | ((rgba.b & 0xFF) << 8) | (rgba.a & 0xFF)
end

---@param rgba_int integer
---@return {r:integer, g:integer, b:integer, a:integer}
function this.int_to_rgba(rgba_int)
    ---@type {r:integer, g:integer, b:integer, a:integer}
    return {
        r = (rgba_int >> 24) & 0xFF,
        g = (rgba_int >> 16) & 0xFF,
        b = (rgba_int >> 8) & 0xFF,
        a = rgba_int & 0xFF,
    }
end

---@param s string
---@param sep string?
---@return string[]
function this.split_string(s, sep)
    if not sep then
        sep = "%s"
    end

    local ret = {}
    for i in string.gmatch(s, "([^" .. sep .. "]+)") do
        table.insert(ret, i)
    end
    return ret
end

---@param int integer
---@return integer
function this.unsigned_to_signed(int)
    local num32 = int & 0xFFFFFFFF --[[@as integer]]
    if num32 > 0x7FFFFFFF then
        return num32 - 0x100000000
    end
    return num32
end

---@param json_str  string
---@return string
function this.compress_json(json_str)
    local result = json_str
    result = result:gsub("%s*([{}%[%],:])%s*", "%1")
    result = result:gsub("[\n\r\t]", "")
    return result
end

---@return integer
function this.get_boot_time()
    return math.floor(os.time() - os.clock())
end

---@param try fun()
---@param catch fun(err: string)?
---@param finally fun(ok: boolean, err: string?)?
---@return boolean
function this.try(try, catch, finally)
    ---@diagnostic disable-next-line: no-unknown
    local ok, err = pcall(try)

    if not ok and catch then
        catch(err)
    end

    if finally then
        finally(ok, err)
    end

    return ok
end

---@param n number
---@param decimals integer
---@return unknown
function this.round(n, decimals)
    local mult = 10 ^ decimals
    return math.floor(n * mult + 0.5) / mult
end

---@param str string
---@param max_len integer?
---@return string
function this.trunc_string(str, max_len)
    max_len = max_len or 25

    if #str > max_len then
        return string.sub(str, 1, max_len - 3) .. "..."
    end

    return str
end

return this
