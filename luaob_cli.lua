-- luaob.lua
-- Usage: lua luaob.lua input.lua output.lua

assert(arg[1], "Missing input file")
assert(arg[2], "Missing output file")

local input  = arg[1]
local output = arg[2]

math.randomseed(os.time())

-- Read source (binary safe)
local f = assert(io.open(input, "rb"))
local src = f:read("*a")
f:close()

-- Compile & dump bytecode
local fn = assert(load(src))
local dumped = string.dump(fn, true)

-- Encrypt
local KEY = math.random(1, 255)
local enc = {}

for i = 1, #dumped do
    enc[i] = dumped:byte(i) ~ KEY
end

-- Emit Lua stub (NO DECRYPTION LOGIC)
local out = assert(io.open(output, "w"))

out:write([[
local luaob = require("luaob")

luaob.run({
    key = ]] .. KEY .. [[,
    data = {
]])

for i = 1, #enc do
    out:write(enc[i])
    if i < #enc then out:write(",") end
end

out:write([[
    }
})
]])

out:close()

print("[LUAOB] Obfuscated:", input, "->", output)
