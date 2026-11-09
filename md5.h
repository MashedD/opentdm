#ifndef MD5_H
#define MD5_H

#include <stddef.h>

#define MD5_DIGEST_LENGTH 16

/*
 * Compute the MD5 digest of a buffer. Only used to build anonymous stats
 * ids, never for anything that needs to be secure.
 */
void MD5_Buffer(const void *data, size_t len,
        unsigned char digest[MD5_DIGEST_LENGTH]);

#endif // MD5_H
