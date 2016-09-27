local json = require "cjson"
local utils = require "kong.tools.utils"
local crypto = require "crypto"

local error = error
local type = type
local pcall = pcall
local ngx_time = ngx.time
local string_rep = string.rep
local setmetatable = setmetatable
local encode_base64 = ngx.encode_base64
local decode_base64 = ngx.decode_base64

--- base 64 decode
-- @param input String to base64 decode
-- @return Base64 decoded string
local function b64_decode(input)
    local reminder = #input % 4

    if reminder > 0 then
        local padlen = 4 - reminder
        input = input..string_rep('=', padlen)
    end

    input = input:gsub("-", "+"):gsub("_", "/")
    return decode_base64(input)
end

--- Tokenize a string by delimiter
-- Used to separate the header, claims and signature part of a JWT
-- @param str String to tokenize
-- @param div Delimiter
-- @param len Number of parts to retrieve
-- @return A table of strings
local function tokenize(str, div, len)
    local result, pos = {}, 0

    for st, sp in function() return str:find(div, pos, true) end do
        result[#result + 1] = str:sub(pos, st-1)
        pos = sp + 1
        len = len - 1
        if len <= 1 then
            break
        end
    end

    result[#result + 1] = str:sub(pos)
    return result
end

--- Parse a JWT
-- Parse a JWT and validate header values.
-- @param token JWT to parse
-- @return A table containing base64 and decoded headers, claims and signature
local function decode_token(token)
    -- Get b64 parts
    local header_64, claims_64, signature_64 = unpack(tokenize(token, ".", 3))

    -- Decode JSON
    local ok, header, claims, signature = pcall(function()
        return json.decode(b64_decode(header_64)),
        json.decode(b64_decode(claims_64)),
        b64_decode(signature_64)
    end)
    if not ok then
        return nil, "invalid JSON"
    end

    if header.typ and header.typ:upper() ~= "JWT" then
        return nil, "invalid typ"
    end

    if not claims then
        return nil, "invalid claims"
    end

    if not signature then
        return nil, "invalid signature"
    end

    return {
        token = token,
        header_64 = header_64,
        claims_64 = claims_64,
        signature_64 = signature_64,
        header = header,
        claims = claims,
        signature = signature
    }
end

-- Extending the Base Plugin handler is optional, as there is no real
-- concept of interface in Lua, but the Base Plugin handler's methods
-- can be called from your child implementation and will print logs
-- in your `error.log` file (where all logs are printed).
local BasePlugin = require "kong.plugins.base_plugin"
local CustomHandler = BasePlugin:extend()

-- Your plugin handler's constructor. If you are extending the
-- Base Plugin handler, it's only role is to instanciate itself
-- with a name. The name is your plugin name as it will be printed in the logs.
function CustomHandler:new()
    CustomHandler.super.new(self, "my-custom-plugin")
end

function CustomHandler:access(config)
    -- Eventually, execute the parent implementation
    -- (will log that your plugin is entering this context)
    CustomHandler.super.access(self)

    local jwt = ngx.req.get_headers()["jwt"]
    if jwt then
        jwt = decode_token(jwt)

        --header_jwt_mapping = ["X-Tenant-ID=tenant", "user=user"]
        for _, value in ipairs(config.header_jwt_mapping) do
            ngx.req.clear_header(header);

            local header, claim = value:match("([^=]+)=([^=]+)")
            ngx.req.set_header(header, jwt.claims[claim])
        end

        ngx.req.clear_header("jwt")
    end
end

-- This module needs to return the created table, so that Kong
-- can execute those functions.
return CustomHandler
