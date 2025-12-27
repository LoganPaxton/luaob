#!/bin/bash

echo "---- Running luaob.lua ----"
lua ./luaob.lua

echo "---- Running add_ob.lua ----"
lua ./testscripts/add_ob.lua
