-- luaob.lua (CLI) [ROBLOX SAFE VERSION]

-- -----------------------
-- Argument handling
-- -----------------------
local input  = arg[1]
local output = arg[2]

if not input or not output then
    io.stderr:write("Usage: lua luaob.lua <input.lua> <output.lua>\n")
    os.exit(1)
end

-- -----------------------
-- Setup
-- -----------------------
math.randomseed(os.time())

-- -----------------------
-- Read source
-- -----------------------
local f = assert(io.open(input, "rb"), "Failed to open input file")
local src = f:read("*a")
f:close()

-- -----------------------
-- Compile to bytecode
-- -----------------------
local fn = assert(load(src), "Failed to compile input")
local dumped = string.dump(fn, true)

-- -----------------------
-- XOR encode
-- -----------------------
local KEY = math.random(1, 255)
local enc = {}

for i = 1, #dumped do
    enc[i] = dumped:byte(i) ~ KEY
end

-- -----------------------
-- Emit loader
-- -----------------------
local out = assert(io.open(output, "w"), "Failed to open output file")

out:write("do\n")
out:write("local _k=" .. KEY .. "\n")
out:write("local _d={")

for i = 1, #enc do
    out:write(enc[i])
    if i < #enc then out:write(",") end
end

out:write("}\n\n")

out:write(
'do local __={math,string,table,load};' ..
'local ___=function()local _=__[1].random(0x3E8);return(_*_)&1==(_&1)end;' ..
'local ____={};local _____=1;' ..
'while true do if ___() then if _____>#_d then break end;' ..
'____[_____]=__[2].char(_d[_____]~_k);_____=_____-(-1);end end;' ..
'local ______=1;' ..
'while true do if ______==1 then _src=__[3].concat(____);______=2 ' ..
'elseif ______==2 then _f=__[4](_src);______=3 ' ..
'elseif ______==3 then _f();break end end end end'
)

out:close()

print("Obfuscated:", input, "->", output)
