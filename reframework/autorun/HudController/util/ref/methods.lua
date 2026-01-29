---@class (partial) MethodUtil
---@field methods table<string, REMethodDefinition>

local types = require("HudController.util.ref.types")
local util_misc = require("HudController.util.misc.init")
local util_ref = require("HudController.util.ref.util")
local logger = require("HudController.util.misc.logger").g
local util_table = require("HudController.util.misc.table")

---@class MethodUtil
local this = {
    methods = {},
}
---@type table<string, integer>
local _debug = {}
local is_debug = false

---@param name string
---@return REMethodDefinition
function this.get(name)
    local type_def, method = util_ref.split_type_def(name)
    local ret = types.get(type_def):get_method(method) --[[@as REMethodDefinition]]

    if not ret then
        logger:error(string.format('Failed to get "%s" method from "%s" type.', method, type_def))
    end

    return ret
end

---@param type_def RETypeDefinition | string
---@param regex string
---@return REMethodDefinition?
function this.get_by_regex(type_def, regex)
    if type(type_def) == "string" then
        type_def = sdk.find_type_definition(type_def) --[[@as RETypeDefinition]]
    end

    local methods = type_def:get_methods()

    for _, m in pairs(methods) do
        local name = m:get_name()
        if string.match(name, regex) then
            return m
        end
    end

    logger:error(
        string.format('Failed to get method with "%s" regex from "%s" type.', regex, type_def)
    )
end

---@param type_def RETypeDefinition | string
---@param name string
---@return REMethodDefinition
function this.t_get(type_def, name)
    ---@type string
    local type_name
    if type(type_def) == "string" then
        type_name = type_def
        type_def = types.get(type_name)
    else
        type_name = type_def:get_full_name()
    end
    ---@cast type_def RETypeDefinition

    local key = string.format("%s.%s", type_name, name)
    if not this.methods[key] then
        this.methods[key] = type_def:get_method(name)
    end

    if not this.methods[key] then
        logger:error(string.format('Failed to get "%s" method from "%s" type.', name, type_name))
    end

    return this.methods[key]
end

---@param method REMethodDefinition
---@return fun(...): any
function this.wrap(method)
    return function(...)
        return method:call(nil, ...)
    end
end

---@param method REMethodDefinition
---@return fun(...): any
function this.wrap_obj(method)
    return function(...)
        return method:call(...)
    end
end

---@param method string | REMethodDefinition
---@param pre_cb (fun(args?: userdata[]): PreHookResult?)?
---@param post_cb (fun(retval?: userdata): any?)?
---@param ignore_jmp_object? boolean
function this.hook(method, pre_cb, post_cb, ignore_jmp_object)
    local method_name = ""
    local method_def = type(method) == "string" and this.get(method) or method --[[@as REMethodDefinition]]

    if type(method) == "string" then
        method_name = method
    else
        method_name = method_def:get_name()
    end

    method_name = string.format(
        "%s [%s]",
        method_name,
        util_misc.integer_to_hex(util_ref.to_int(method_def:get_function()))
    )

    if not pre_cb and not post_cb then
        logger:error("No callbacks: " .. method_name)
    end

    if is_debug then
        pre_cb = pre_cb or function(args) end
        if post_cb then
            local o_post_cb = post_cb
            post_cb = function(retval)
                if not _debug[method_name] then
                    _debug[method_name] = 1
                else
                    _debug[method_name] = _debug[method_name] + 1
                end
                return o_post_cb(retval)
            end
        end

        local o_pre_cb = pre_cb
        pre_cb = function(args)
            if not _debug[method_name] then
                _debug[method_name] = 1
            else
                _debug[method_name] = _debug[method_name] + 1
            end
            return o_pre_cb(args)
        end
    end

    util_misc.try(function()
        sdk.hook(
            ---@diagnostic disable-next-line: param-type-mismatch
            method_def,
            pre_cb or function(args) end,
            post_cb and util_ref.hook_ret(post_cb) or nil,
            ignore_jmp_object
        )
    end, function(err)
        ---@diagnostic disable-next-line: param-type-mismatch
        logger:error(string.format("Failed to hook %s: %s", method_name, err))
    end)
end

if is_debug then
    re.on_frame(function()
        util_table.print(_debug)
        _debug = {}
    end)
end

return this
