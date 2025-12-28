extern "C" {
#include "lua.h"
#include "lauxlib.h"
}

#include <vector>
#include <cstdint>
#include <algorithm>

#include "includes/utils/utils.h"

static void read_byte_table(lua_State* L, int idx, uint8_t* out, size_t expected) {
    luaL_checktype(L, idx, LUA_TTABLE);

    size_t len = lua_rawlen(L, idx);
    luaL_argcheck(L, len == expected, idx, "invalid length");

    for (size_t i = 0; i < expected; i++) {
        lua_rawgeti(L, idx, i + 1);
        out[i] = (uint8_t)(luaL_checkinteger(L, -1) & 0xFF);
        lua_pop(L, 1);
    }
}

static int luaob_run(lua_State* L) {
    luaL_checktype(L, 1, LUA_TTABLE);

    uint8_t key[32];
    uint8_t iv[16];

    // key
    lua_getfield(L, 1, "key");
    read_byte_table(L, -1, key, sizeof(key));
    lua_pop(L, 1);

    // iv / nonce
    lua_getfield(L, 1, "iv");
    read_byte_table(L, -1, iv, sizeof(iv));
    lua_pop(L, 1);

    // encrypted data
    lua_getfield(L, 1, "data");
    luaL_checktype(L, -1, LUA_TTABLE);

    size_t len = lua_rawlen(L, -1);
    std::vector<uint8_t> buf(len);

    for (size_t i = 0; i < len; i++) {
        lua_rawgeti(L, -1, i + 1);
        buf[i] = (uint8_t)(luaL_checkinteger(L, -1) & 0xFF);
        lua_pop(L, 1);
    }
    lua_pop(L, 1);

    // AES-CTR decrypt (in-place)
    aes_ctr_decrypt(buf, key, iv);

    // load bytecode (force binary)
    if (luaL_loadbufferx(
            L,
            reinterpret_cast<const char*>(buf.data()),
            buf.size(),
            "luaob",
            "b"
        ) != LUA_OK) {

        std::fill(buf.begin(), buf.end(), 0);
        return lua_error(L);
    }

    // execute
    if (lua_pcall(L, 0, 0, 0) != LUA_OK) {
        std::fill(buf.begin(), buf.end(), 0);
        return lua_error(L);
    }

    // wipe sensitive memory
    std::fill(buf.begin(), buf.end(), 0);
    std::fill(std::begin(key), std::end(key), 0);
    std::fill(std::begin(iv), std::end(iv), 0);

    return 0;
}

extern "C" int luaopen_luaob(lua_State* L) {
    lua_newtable(L);
    lua_pushcfunction(L, luaob_run);
    lua_setfield(L, -2, "run");
    return 1;
}
