// Species sets as fixed-width bitmaps indexed by species.index_num.
//
// The server sends sparse index lists; those are expanded here once, at load.
// Clusters then OR their members' bitmaps and count bits, which keeps cluster
// species totals exact without a request per cluster.

var POPCOUNT = new Uint8Array(256);
for (var i = 1; i < 256; i++) {
  POPCOUNT[i] = POPCOUNT[i >> 1] + (i & 1);
}

export function countBits(bytes) {
  var total = 0;
  for (var i = 0; i < bytes.length; i++) {
    total += POPCOUNT[bytes[i]];
  }
  return total;
}

// Builds bitmaps and counts distinct species across them. The union reuses one
// scratch buffer so that re-clustering on every zoom does not allocate.
export function createSpeciesBitmaps(indexSize) {
  var byteSize = Math.ceil(indexSize / 8);
  var scratch = new Uint8Array(byteSize);

  return {
    byteSize: byteSize,

    build: function (indexes) {
      var bytes = new Uint8Array(byteSize);
      for (var i = 0; i < indexes.length; i++) {
        var index = indexes[i];
        bytes[index >> 3] |= 1 << (index & 7);
      }
      return bytes;
    },

    unionCount: function (bitmaps) {
      if (bitmaps.length === 1) return countBits(bitmaps[0]);

      scratch.fill(0);
      for (var i = 0; i < bitmaps.length; i++) {
        var bits = bitmaps[i];
        for (var b = 0; b < byteSize; b++) {
          scratch[b] |= bits[b];
        }
      }
      return countBits(scratch);
    }
  };
}
