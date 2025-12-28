#pragma once

#include <openssl/evp.h>
#include <vector>
#include <cstdint>

void aes_ctr_decrypt(std::vector<uint8_t>& buf, const uint8_t* key, const uint8_t* iv);