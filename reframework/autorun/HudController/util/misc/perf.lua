---@class (exact) PerfStats
---@field it integer
---@field total number
---@field min number
---@field max number
---@field mean number
---@field median number
---@field p95 number
---@field p99 number
---@field stddev number

local this = {}

---@return integer
local function get_time()
    if hudcontroller_util then
        return hudcontroller_util.now_us()
    end

    return os.clock() * 1000000
end

---@param measurements integer[]
---@return PerfStats
local function calc_stats(measurements)
    table.sort(measurements)

    local sum = 0
    for i = 1, #measurements do
        sum = sum + measurements[i]
    end

    local mean = sum / #measurements
    local min = measurements[1]
    local max = measurements[#measurements]

    local function percentile(p)
        local index = math.ceil(p * #measurements / 100)
        return measurements[math.max(1, math.min(index, #measurements))]
    end

    local variance_sum = 0
    for i = 1, #measurements do
        local diff = measurements[i] - mean
        variance_sum = variance_sum + (diff * diff)
    end

    ---@type PerfStats
    return {
        it = #measurements,
        total = sum,
        min = min,
        max = max,
        mean = mean,
        median = percentile(50),
        p95 = percentile(95),
        p99 = percentile(99),
        stddev = math.sqrt(variance_sum / (#measurements - 1)),
    }
end

---@param microseconds number
---@return string
local function format_time(microseconds)
    if microseconds < 1000 then
        return string.format("%.2f μs", microseconds)
    elseif microseconds < 1000000 then
        return string.format("%.2f ms", microseconds / 1000)
    else
        return string.format("%.2f s", microseconds / 1000000)
    end
end

---@param fn fun(...): any
---@param it integer? by default, 100
---@param name string?
---@param ignore_below_n number?
---@return fun(...): any
function this.perf(fn, it, name, ignore_below_n)
    it = it or 100
    ignore_below_n = ignore_below_n or -1
    name = name or ""
    local measurements = {}
    local count = 0

    return function(...)
        if count == it then
            local ret = fn(...)
            return ret
        end

        local s = get_time()
        local ret = fn(...)
        local e = get_time()
        local t = e - s

        if t < ignore_below_n then
            return ret
        end

        count = count + 1
        table.insert(measurements, t)

        if count == it then
            local stats = calc_stats(measurements)
            local str = string.format("--Performance: %s\nit: %s", name, stats["it"])
            local keys = { "total", "min", "max", "mean", "median", "p95", "p99", "stddev" }
            for i = 1, #keys do
                local key = keys[i]
                str = string.format("%s\n%s: %s", str, key, format_time(stats[key]))
            end

            log.debug(str)
        end

        return ret
    end
end

return this
