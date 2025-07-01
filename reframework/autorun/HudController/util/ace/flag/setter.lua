---@class (exact) FlagSetterArg
---@field obj AceFlags
---@field flag integer
---@field frame_count boolean
---@field is_set boolean
---@field state boolean
---@field restore boolean?

local this = {}
---@type FlagSetterArg[]
local queue = {}

---@param obj AceFlags
---@param flag integer
---@param state boolean
local function set_flag(obj, flag, state)
    if state then
        obj:on(flag)
    else
        obj:off(flag)
    end
end

---@param flag_obj AceFlags
---@param flag integer
---@param state boolean
---@param frame_count integer
---@param restore boolean?
function this.add(flag_obj, flag, state, frame_count, restore)
    local o = {
        obj = flag_obj,
        flag = flag,
        state = state,
        frame_count = frame_count,
    }

    if restore then
        local def = flag_obj:get_type_definition() --[[@as RETypeDefinition]]
        if def:is_a("ace.cSafeContinueFlagGroup") or def:is_a("ace.cSafeContinueFlag") then
            ---@cast flag_obj ace.cSafeContinueFlagGroup
            o.restore = flag_obj:check(flag)
        else
            o.restore = flag_obj:call("isOn(System.Int32)", flag)
        end
    end

    table.insert(queue, o)
end

function this.iter()
    for i = 1, #queue do
        local flag = queue[i]
        if flag.frame_count <= 0 then
            if flag.is_set and flag.restore ~= nil then
                set_flag(flag.obj, flag.flag, flag.restore)
            end

            queue[i] = nil
            goto continue
        end

        if not flag.is_set then
            set_flag(flag.obj, flag.flag, flag.state)
            flag.is_set = true
        end

        flag.frame_count = flag.frame_count - 1
        ::continue::
    end
end

return this
