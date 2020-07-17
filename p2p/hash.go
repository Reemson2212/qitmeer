/*
 * Copyright (c) 2020.
 * Project:qitmeer
 * File:hash.go
 * Date:7/15/20 11:01 AM
 * Author:Jin
 * Email:lochjin@gmail.com
 */

package p2p

import (
	"github.com/Qitmeer/qitmeer/common"
	"github.com/minio/highwayhash"
)

// Key used for FastSum64
var fastSumHashKey = common.ToBytes32([]byte("hash_fast_sum64_key"))

// FastSum64 returns a hash sum of the input data using highwayhash. This method is not secure, but
// may be used as a quick identifier for objects where collisions are acceptable.
func FastSum64(data []byte) uint64 {
	return highwayhash.Sum64(data, fastSumHashKey[:])
}

// FastSum256 returns a hash sum of the input data using highwayhash. This method is not secure, but
// may be used as a quick identifier for objects where collisions are acceptable.
func FastSum256(data []byte) [32]byte {
	return highwayhash.Sum(data, fastSumHashKey[:])
}
