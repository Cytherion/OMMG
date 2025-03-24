-- utils/logger.lua

local logger = {}

function logger.info(fmt, ...)
    print(string.format("[INFO] " .. fmt, ...))
end

function logger.warn(fmt, ...)
    print(string.format("[WARN] " .. fmt, ...))
end

function logger.error(fmt, ...)
    print(string.format("[ERROR] " .. fmt, ...))
end

function logger.success(fmt, ...)
    print(string.format("[SUCCESS] " .. fmt, ...))
end

return logger
