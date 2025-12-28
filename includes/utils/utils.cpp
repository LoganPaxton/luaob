#include "utils.h"
#include <openssl/evp.h>
#include <vector>
#include <cstdint>

void aes_ctr_decrypt(
    std::vector<uint8_t>& buf,
    const uint8_t* key,
    const uint8_t* iv
) {
    EVP_CIPHER_CTX* ctx = EVP_CIPHER_CTX_new();

    EVP_DecryptInit_ex(ctx, EVP_aes_256_ctr(), nullptr, key, iv);

    int outlen;
    EVP_DecryptUpdate(ctx, buf.data(), &outlen, buf.data(), buf.size());

    EVP_CIPHER_CTX_free(ctx);
}
