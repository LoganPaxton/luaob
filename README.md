# LUAOB

**LUAOB** is a Lua bytecode obfuscator that compiles Lua source code into bytecode, encrypts it, and emits a heavily‑obfuscated runtime loader that reconstructs and executes the original program at runtime.

This tool is designed to make Lua scripts **difficult to read, analyze, and reverse**, while remaining **fully Lua‑VM compatible**.

---

## ✨ Features

* Compiles Lua source to **bytecode** using `string.dump`
* Encrypts bytecode with **XOR**
* Emits a **self‑decoding runtime loader**
* Uses:

  * Opaque predicates
  * Control‑flow flattening
  * One‑liner loader logic
* No external dependencies
* Works with Lua **5.1 – 5.4**

> ⚠️ This is obfuscation, not DRM.
> If Lua can execute it, a determined attacker can eventually reverse it.

---

## 📦 Installation

No installation required.
Just make sure you have Lua installed:

```bash
lua -v
```

---

## 🚀 Usage

```bash
lua luaob.lua <input.lua> <output.lua>
```

### Example

```bash
lua luaob.lua testscripts/add.lua testscripts/add_ob.lua
lua testscripts/add_ob.lua
```

---

## 🧠 How It Works (High Level)

1. Reads the input Lua source
2. Compiles it into Lua bytecode
3. Encrypts the bytecode using XOR
4. Emits a loader that:

   * Decodes the bytecode at runtime
   * Reconstructs it into a string
   * Executes it using `load()`
   * Uses obfuscated control flow to hinder analysis

The original source code does **not** exist in plaintext in the output file.

---

## 🧪 Example Output (Excerpt)

```lua
do
local _k=69
local _d={94,9,48,36,...}
do local __={math,string,table,load};local ___=function()...
```

---

## 🔒 Security Notes

* Designed to stop **casual inspection and copying**
* Not resistant to:

  * Memory dumping
  * Bytecode decompilation
  * Runtime instrumentation
* Best used for:

  * Script protection
  * Distribution hardening
  * Deterring low‑effort theft

---

## 🛠 Limitations

* Does not protect against skilled reverse‑engineers
* Output size increases significantly
* Debugging obfuscated output is impractical
* Lua syntax errors in the input will propagate

---

## 📌 Roadmap

* Deterministic key support (`--key`)
* Rolling XOR key per byte
* Base64 encoding for bytecode table
* Anti‑dump checks
* Batch directory obfuscation

---

## 📄 License

MIT — do whatever you want, just don’t pretend this is unbreakable.

---

## ⚡ Final Word

LUAOB makes Lua scripts **painful to read**, **annoying to analyze**, and **safe enough** for real‑world distribution — without breaking the Lua VM.

If it runs, it can be reversed.
This just makes the job **much harder**.