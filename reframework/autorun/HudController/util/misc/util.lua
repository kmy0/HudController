local this = {}

---@param rgba {r:integer, g:integer, b:integer, a:integer}
function this.rgba_to_int(rgba)
    return ((rgba.r & 0xFF) << 24)
        | ((rgba.g & 0xFF) << 16)
        | ((rgba.b & 0xFF) << 8)
        | (rgba.a & 0xFF)
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
    local ret = {}

    if not sep then
        for w in s:gmatch("%S+") do
            table.insert(ret, w)
        end

        return ret
    end

    local pos = 1
    while true do
        local found = s:find(sep, pos, true)
        if not found then
            table.insert(ret, s:sub(pos))
            break
        end

        table.insert(ret, s:sub(pos, found - 1))
        pos = found + #sep
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
---@return number
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

---@param text string
---@param max_width number
---@return string
function this.trunc_string2(text, max_width)
    if imgui.calc_text_size(text).x <= max_width then
        return text
    end

    local suffix = "..."
    local suffix_width = imgui.calc_text_size(suffix).x

    while #text > 0 do
        text = text:sub(1, -2)

        if imgui.calc_text_size(text).x + suffix_width <= max_width then
            return text .. suffix
        end
    end

    return suffix
end

---@param path string
---@param ext boolean? by default, true
---@return string
function this.get_file_name(path, ext)
    ext = ext == nil and true or ext
    local ret = path:match("([^/\\]+)$")

    if not ext then
        ret = ret:match("(.+)%..+$") --[[@as string]]
    end

    return ret
end

---@param path string
---@return boolean
function this.file_exists(path)
    local handle = io.open(path, "r")
    if handle then
        handle:close()
        return true
    end
    return false
end

---@param ... string
---@return string
function this.join_paths(...)
    local res = table.concat({ ... }, "/"):gsub("\\", "/")
    res = res:gsub("/+", "/")
    return res
end

-- backslashes
---@param ... string
---@return string
function this.join_paths_b(...)
    local res = this.join_paths(...)
    res = res:gsub("/", "\\\\")
    return res
end

---@param bit integer
---@return integer[]
function this.extract_bits(bit)
    local ret = {}

    while bit ~= 0 do
        local lowest_bit = bit & -bit --[[@as integer]]
        table.insert(ret, lowest_bit)
        bit = bit & (bit - 1) --[[@as integer]]
    end

    return ret
end

---@param text string
---@param width integer
function this.wrap_text(text, width)
    local lines = {}
    local cur_line = ""

    for word in text:gmatch("%S+") do
        while #word > width do
            if #cur_line > 0 then
                table.insert(lines, cur_line)
                cur_line = ""
            end

            local part = word:sub(1, width)
            table.insert(lines, part)
            word = word:sub(width + 1)
        end

        if #word > 0 then
            if #cur_line == 0 then
                cur_line = word
            elseif #cur_line + 1 + #word <= width then
                cur_line = cur_line .. " " .. word
            else
                table.insert(lines, cur_line)
                cur_line = word
            end
        end
    end

    if #cur_line > 0 then
        table.insert(lines, cur_line)
    end

    return table.concat(lines, "\n")
end

---@param n number
---@param min number
---@param max number
---@return number
function this.wrap_number(n, min, max)
    if n > max then
        return min
    end

    if n < min then
        return max
    end

    return n
end

---@param num integer
function this.integer_to_hex(num)
    return string.format("0x%x", num)
end

---@param module_name string
function this.lazy_require(module_name)
    return setmetatable({}, {
        __index = function(_, key)
            return require(module_name)[key]
        end,
    })
end

---@param fn fun()
function this.with_custom_require(fn)
    local original_require = _G.require

    ---@param name string
    ---@diagnostic disable-next-line: duplicate-set-field
    _G.require = function(name)
        ---@type string?
        local err
        ---@type any?
        local ret

        this.try(function()
            ---@diagnostic disable-next-line: no-unknown
            ret = original_require(name)
        end, function(error)
            err = error
        end)

        if not err then
            return ret
        elseif not err:find("module.-not found") then
            error(err, 0)
        end

        this.try(function()
            ---@diagnostic disable-next-line: no-unknown
            ret = original_require("reframework.autorun." .. name)
        end)

        if not ret then
            error(err, 0)
        end

        ---@diagnostic disable-next-line: no-unknown
        package.loaded[name] = ret

        return ret
    end

    fn()

    _G.require = original_require
end

---@param text string
---@param pos_x number
---@param pos_y number
---@param area_w number?
---@param area_h number?
---@return number, number
function this.clamp_text(text, pos_x, pos_y, area_w, area_h)
    if not area_w and not area_h then
        local screen = imgui.get_display_size()
        area_w = screen.x
        area_h = screen.y
    end

    local text_size = imgui.calc_text_size(text)
    local clamped_x = math.max(0, math.min(pos_x, area_w - text_size.x))
    local clamped_y = math.max(0, math.min(pos_y, area_h - text_size.y))
    return clamped_x, clamped_y
end

---@param pos_x number
---@param pos_y number
---@param size_w number
---@param size_h number
---@param stick number? fraction to keep outside (e.g. 0.5 = half, 0.25 = quarter) by default, 0.5
---@param area_w number?
---@param area_h number?
---@return number, number
function this.clamp_figure(pos_x, pos_y, size_w, size_h, stick, area_w, area_h)
    stick = stick or 0.5

    if not area_w and not area_h then
        local screen = imgui.get_display_size()
        area_w = screen.x
        area_h = screen.y
    end

    local margin_w = size_w * stick
    local margin_h = size_h * stick

    local clamped_x = math.max(-(size_w - margin_w), math.min(pos_x, area_w - margin_w))
    local clamped_y = math.max(-(size_h - margin_h), math.min(pos_y, area_h - margin_h))

    return clamped_x, clamped_y
end

---@param pos_x number
---@param pos_y number
---@param radius number
---@param stick number? fraction of diameter still visible (e.g. 0.25 = quarter visible). default 0.5
---@param area_w number?
---@param area_h number?
---@return number, number
function this.clamp_circle(pos_x, pos_y, radius, stick, area_w, area_h)
    stick = stick or 0.5

    if not area_w and not area_h then
        local screen = imgui.get_display_size()
        area_w = screen.x
        area_h = screen.y
    end

    local visible = radius * 2 * stick

    return math.max(visible - radius, math.min(pos_x, area_w - visible + radius)),
        math.max(visible - radius, math.min(pos_y, area_h - visible + radius))
end

---@param pos {x: number, y: number}
---@param size {x: number, y: number}
---@param point {x: number, y: number}
---@return boolean
function this.is_inside_rect(pos, size, point)
    return point.x >= pos.x
        and point.x <= pos.x + size.x
        and point.y >= pos.y
        and point.y <= pos.y + size.y
end

---@param center {x: number, y: number}
---@param radius number
---@param point {x: number, y: number}
---@return boolean
function this.is_inside_circle(center, radius, point)
    local dx = point.x - center.x
    local dy = point.y - center.y
    return dx * dx + dy * dy <= radius * radius
end

---@return fun(pos: {x: number, y: number}, area_size: {x: number, y: number}, mouse_pos: {x: number, y: number}, trigger: boolean, clamp_to_screen: boolean?): boolean, number, number
function this.dragable()
    local trigger_last_frame = false
    ---@type {x: number, y: number}
    local o_pos
    ---@type {x: number, y: number}
    local o_mouse_pos
    local drag = false

    return function(pos, area_size, mouse_pos, trigger, clamp_to_screen)
        if trigger and not trigger_last_frame then
            o_pos = pos
            o_mouse_pos = mouse_pos
            drag = this.is_inside_rect(pos, area_size, mouse_pos)
        elseif not trigger then
            drag = false
        end

        trigger_last_frame = trigger
        if not drag then
            return false, pos.x, pos.y
        end

        local dist_x = o_mouse_pos.x - mouse_pos.x
        local dist_y = o_mouse_pos.y - mouse_pos.y
        local ret_x = o_pos.x - dist_x
        local ret_y = o_pos.y - dist_y

        if clamp_to_screen then
            ret_x, ret_y = this.clamp_figure(ret_x, ret_y, area_size.x, area_size.y)
        end

        return true, ret_x, ret_y
    end
end

---@param n integer
---@return string
function this.to_base36(n)
    local chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local result = ""
    repeat
        result = chars:sub((n % 36) + 1, (n % 36) + 1) .. result
        n = math.floor(n / 36)
    until n == 0
    return result
end

---@param col integer
---@param factor number 0.0 - 1.0
---@return integer
function this.mul_alpha(col, factor)
    local a = math.floor(((col >> 24) & 0xFF) * factor)
    return (col & 0x00FFFFFF) | (a << 24)
end

---@param t integer[]
---@return integer
function this.pack_bits(t)
    local bits = 0
    for _, val in ipairs(t) do
        bits = bits | (1 << (val - 1))
    end
    return bits
end

---@param bits integer
---@return integer[]
function this.unpack_bits(bits)
    local indexes = {}
    local i = 1

    while bits ~= 0 do
        if (bits & 1) ~= 0 then
            table.insert(indexes, i)
        end

        bits = bits >> 1
        i = i + 1
    end

    return indexes
end

return this
