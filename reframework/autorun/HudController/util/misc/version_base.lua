---@class Version
---@field major number
---@field minor number
---@field patch number
---@field commit number

---@class Version
local this = {}
this.__index = this

---@param version_string string 0.0.0-0
---@return Version
function this.new(version_string)
    local major, minor, patch = version_string:match("(%d+)%.(%d+)%.(%d+)")
    local commit = version_string:match("%-(%d+)") or "0"

    local o = {
        major = tonumber(major),
        minor = tonumber(minor),
        patch = tonumber(patch),
        commit = tonumber(commit) or 0,
    }
    return setmetatable(o, this) --[[@as Version]]
end

---@param a Version
---@param b Version
---@return boolean
function this.__lt(a, b)
    if a.major ~= b.major then
        return a.major < b.major
    end
    if a.minor ~= b.minor then
        return a.minor < b.minor
    end
    if a.patch ~= b.patch then
        return a.patch < b.patch
    end
    return a.commit < b.commit
end

---@param a Version
---@param b Version
---@return boolean
function this.__eq(a, b)
    return a.major == b.major and a.minor == b.minor and a.patch == b.patch and a.commit == b.commit
end

---@param a Version
---@param b Version
---@return boolean
function this.__le(a, b)
    return a < b or a == b
end

---@param a Version
---@param b Version
---@return boolean
function this.__gt(a, b)
    return not (a <= b)
end

---@param a Version
---@param b Version
---@return boolean
function this.__ge(a, b)
    return not (a < b)
end

---@return string
function this:__tostring()
    if self.commit > 0 then
        return string.format(
            "Version(%d.%d.%d-%d)",
            self.major,
            self.minor,
            self.patch,
            self.commit
        )
    end
    return string.format("Version(%d.%d.%d)", self.major, self.minor, self.patch)
end

return this
