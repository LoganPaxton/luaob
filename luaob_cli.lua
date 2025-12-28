-- luaob_cli.lua
-- Usage: lua luaob_cli.lua input.lua output.lua

assert(arg[1], "Missing input file")
assert(arg[2], "Missing output file")

local input  = arg[1]
local output = arg[2]

-- Read source
local f = assert(io.open(input, "rb"))
local src = f:read("*a")
f:close()

-- Compile & dump bytecode
local fn = assert(load(src))
local dumped = string.dump(fn, true)

-- Write bytecode to temp file
local tmp_plain = os.tmpname()
local tmp_enc   = os.tmpname()

do
    local t = assert(io.open(tmp_plain, "wb"))
    t:write(dumped)
    t:close()
end

-- Generate key + iv
local key = {}
local iv  = {}

for i = 1, 32 do key[i] = math.random(0,255) end
for i = 1, 16 do iv[i]  = math.random(0,255) end

-- Write key/iv as hex
--[[local function tohex(t)
    return table.concat(t, "", function(b) return string.format("%02x", b) end)
end]]--

local key_hex = ""
for _,b in ipairs(key) do key_hex = key_hex .. string.format("%02x", b) end

local iv_hex = ""
for _,b in ipairs(iv) do iv_hex = iv_hex .. string.format("%02x", b) end

-- Encrypt using OpenSSL AES-256-CTR
os.execute(string.format(
    "openssl enc -aes-256-ctr -K %s -iv %s -nosalt -in %s -out %s",
    key_hex, iv_hex, tmp_plain, tmp_enc
))

-- Read encrypted output
local ef = assert(io.open(tmp_enc, "rb"))
local enc = { ef:read("*all"):byte(1, -1) }
ef:close()

os.remove(tmp_plain)
os.remove(tmp_enc)

-- Emit Lua stub
local out = assert(io.open(output, "w"))

out:write("local luaob = require(\"luaob\")\n\n")
out:write("luaob.run({\n")

out:write("  key = {")
for i,b in ipairs(key) do
    out:write(b)
    if i < #key then out:write(",") end
end
out:write("},\n")

out:write("  iv = {")
for i,b in ipairs(iv) do
    out:write(b)
    if i < #iv then out:write(",") end
end
out:write("},\n")

out:write("  data = {")
for i,b in ipairs(enc) do
    out:write(b)
    if i < #enc then out:write(",") end
end
out:write("}\n")

out:write("})\n")
out:close()

print("[LUAOB] AES-CTR obfuscated:", input, "->", output)
