extern "C" {
#include "lua.h"
#include "lauxlib.h"
}

#include <vector>
#include <cstdint>
#include <algorithm>

static int luaob_run(lua_State* L) {
    luaL_checktype(L, 1, LUA_TTABLE);

    // key
    lua_getfield(L, 1, "key");
    int key = luaL_checkinteger(L, -1) & 0xFF;
    lua_pop(L, 1);

    // data
    lua_getfield(L, 1, "data");
    luaL_checktype(L, -1, LUA_TTABLE);

    size_t len = lua_rawlen(L, -1);
    std::vector<uint8_t> buf(len);

    for (size_t i = 0; i < len; i++) {
        lua_rawgeti(L, -1, i + 1);
        int v = luaL_checkinteger(L, -1) & 0xFF;
        lua_pop(L, 1);
        buf[i] = static_cast<uint8_t>(v ^ key);
    }

    lua_pop(L, 1);

    // load bytecode (FORCE binary)
    if (luaL_loadbufferx(
            L,
            reinterpret_cast<const char*>(buf.data()),
            buf.size(),
            "luaob",
            "b"
        ) != LUA_OK) {
        return lua_error(L);
    }

    // execute
    if (lua_pcall(L, 0, 0, 0) != LUA_OK) {
        return lua_error(L);
    }

    // wipe buffer
    std::fill(buf.begin(), buf.end(), 0);

    return 0;
}

extern "C" int luaopen_luaob(lua_State* L) {
    lua_newtable(L);
    lua_pushcfunction(L, luaob_run);
    lua_setfield(L, -2, "run");
    return 1;
}
