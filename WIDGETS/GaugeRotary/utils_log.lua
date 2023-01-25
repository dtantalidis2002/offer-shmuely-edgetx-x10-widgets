local app_name, script_dir = ...
local ENABLE_LOG_FILE=true
local current_level_str = "info"        -- info | no_logs

local M = {}
M.app_name = app_name
M.script_dir = script_dir

local log = {
    outfile = script_dir .. "/app.log",
    enable_file = ENABLE_LOG_FILE,
    current_level = nil,

    -- func
    trace = nil,
    debug = nil,
    info = nil,
    warn = nil,
    error = nil,
    fatal = nil,

    levels = {
        trace = 1,
        debug = 2,
        info = 3,
        warn = 4,
        error = 5,
        fatal = 6,
        no_logs = 99
    }
}

log.current_level = log.levels[current_level_str]


local function round(x, increment)
    increment = increment or 1
    x = x / increment
    return (x > 0 and math.floor(x + .5) or math.ceil(x - .5)) * increment
end

local _tostring = tostring

local function tostring(...)
    local t = {}
    for i = 1, select('#', ...) do
        local x = select(i, ...)
        if type(x) == "number" then
            x = round(x, .01)
        end
        t[#t + 1] = _tostring(x)
    end
    return table.concat(t, " ")
end

function M.do_log(iLevel, ulevel, fmt, ...)
    if iLevel < log.current_level then
        --below the log level
        return
    end

    local num_arg = #{ ... }
    local msg
    if num_arg > 0 then
        msg = string.format(fmt, ...)
    else
        msg = fmt
    end

    local lineinfo = "f.lua:0"
    local msg2 = string.format("[%-4s] %s: %s", ulevel, lineinfo, msg)

    -- output to console
    print(msg2)

    -- Output to log file
    if log.enable_file == true and log.outfile then
        local fp = io.open(log.outfile, "a")
        io.write(fp, msg2 .. "\n")
        io.close(fp)
    end
end

function M.trace(fmt, ...)
    M.do_log(log.levels.trace, "TRACE", fmt, ...)
end
function M.debug(fmt, ...)
    M.do_log(log.levels.debug, "DEBUG", fmt, ...)
end
function M.info(fmt, ...)
    M.do_log(log.levels.info, "INFO", fmt, ...)
end
function M.warn(fmt, ...)
    M.do_log(log.levels.warn, "WARN", fmt, ...)
end
function M.error(fmt, ...)
    M.do_log(log.levels.error, "ERROR", fmt, ...)
end
function M.fatal(fmt, ...)
    M.do_log(log.levels.fatal, "FATAL", fmt, ...)
end

return M
