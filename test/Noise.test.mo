import { test; suite; expect } "mo:test";
import Nat64 "mo:base/Nat64";
import Float "mo:base/Float";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Random "../src/Random";
import Noise "../src/Noise";
import T "../src/Types";

suite(
  "Noise Functions",
  func() {
    let seed : Nat64 = 1234567890123456789;

    test(
      "xPerlinInit",
      func() {
        let xoroshiro = Random.xSetSeed(seed);
        let perlinNoise = Noise.xPerlinInit(xoroshiro);

        // Check that the Perlin noise instance is initialized correctly
        assert perlinNoise.a != 0.0;
        assert perlinNoise.b != 0.0;
        assert perlinNoise.c != 0.0;
        assert perlinNoise.amplitude == 1.0;
        assert perlinNoise.lacunarity == 1.0;

        expect.nat(perlinNoise.d.size()).equal(512);

        // Check that the permutation array is correctly shuffled
        var isShuffled = false;
        label shuffleCheck for (i in Iter.range(0, 255)) {
          if (perlinNoise.d[i] != Nat32.fromNat(i)) {
            isShuffled := true;
            break shuffleCheck;
          };
        };
        expect.bool(isShuffled).equal(true);
      },
    );

    test(
      "xOctaveInit",
      func() {
        let xoroshiro = Random.xSetSeed(seed);
        let amplitudes : [Float] = [1.0, 0.5, 0.25];
        let octaves = Noise.xOctaveInit(xoroshiro, amplitudes, -3, amplitudes.size(), 3);

        // Check that the Octaves instance is initialized correctly
        expect.nat(octaves.size()).equal(3);

        for (i in Iter.range(0, octaves.size() - 1)) {
          let perlinNoise = octaves.get(i);
          assert perlinNoise.amplitude != 0.0;
          assert perlinNoise.lacunarity != 0.0;
        };
      },
    );

    test(
      "xDoublePerlinInit",
      func() {
        let xoroshiro = Random.xSetSeed(seed);
        let amplitudes : [Float] = [1.0, 0.5, 0.25];
        let doublePerlinNoise = Noise.xDoublePerlinInit(xoroshiro, amplitudes, -3, amplitudes.size(), 3);

        // Check that the Double Perlin noise instance is initialized correctly
        assert doublePerlinNoise.amplitude != 0.0;
        expect.nat(doublePerlinNoise.octaveNoise1.size()).equal(2);
        expect.nat(doublePerlinNoise.octaveNoise2.size()).equal(1);
      },
    );

    test(
      "samplePerlinNoise",
      func() {
        let xoroshiro = Random.xSetSeed(seed);
        let perlinNoise = Noise.xPerlinInit(xoroshiro);

        // Sample the Perlin noise at a given point
        let noiseValue = Noise.samplePerlinNoise(perlinNoise, 0.5, 0.5, 0.5, 0.0, 0.0);

        // Check that the noise value is within the expected range
        assert noiseValue >= -1.0;
        assert noiseValue <= 1.0;
      },
    );

    test(
      "sampleOctaves",
      func() {
        let xoroshiro = Random.xSetSeed(seed);
        let amplitudes : [Float] = [1.0, 0.5, 0.25];
        let octaves = Noise.xOctaveInit(xoroshiro, amplitudes, 0, amplitudes.size(), 3);

        // Sample the Octave noise at a given point
        let noiseValue = Noise.sampleOctaves(octaves, 0.5, 0.5, 0.5);

        // Check that the noise value is within the expected range
        assert noiseValue >= -1.0;
        assert noiseValue <= 1.0;
      },
    );

    test(
      "sampleDoublePerlinNoise",
      func() {
        let xoroshiro = Random.xSetSeed(seed);
        let amplitudes : [Float] = [1.0, 0.5, 0.25];
        let doublePerlinNoise = Noise.xDoublePerlinInit(xoroshiro, amplitudes, 0, amplitudes.size(), 3);

        // Sample the Double Perlin noise at a given point
        let noiseValue = Noise.sampleDoublePerlinNoise(doublePerlinNoise, 0.5, 0.5, 0.5);

        // Check that the noise value is within the expected range
        assert noiseValue >= -1.0;
        assert noiseValue <= 1.0;
      },
    );

    test(
      "getVoronoiSrcRange",
      func() {
        let range : T.Range = {
          var scale = 1;
          var x = 0;
          var y = 0;
          var z = 0;
          var sx = 16;
          var sz = 16;
          var sy = 16;
        };
        let srcRange = Noise.getVoronoiSrcRange(range);

        // Check that the source range is computed correctly
        expect.int32(srcRange.x).equal(-1);
        expect.int32(srcRange.z).equal(-1);
        expect.int32(srcRange.sx).equal(6);
        expect.int32(srcRange.sz).equal(6);
        expect.int32(srcRange.y).equal(-1);
        expect.int32(srcRange.sy).equal(6);
      },
    );

    test(
      "getVoronoiCell",
      func() {
        let sha : Nat64 = 1234567890123456789;
        let (x, y, z) = Noise.getVoronoiCell(sha, 0, 0, 0);

        // Check that the Voronoi cell coordinates are within the expected range
        expect.int64(x).greaterOrEqual(-18432);
        expect.int64(x).lessOrEqual(18432);
        expect.int64(y).greaterOrEqual(-18432);
        expect.int64(y).lessOrEqual(18432);
        expect.int64(z).greaterOrEqual(-18432);
        expect.int64(z).lessOrEqual(18432);
      },
    );

    test(
      "voronoiAccess3D",
      func() {
        let sha : Nat64 = 1234567890123456789;
        let (x, y, z) = Noise.voronoiAccess3D(sha, 0, 0, 0);

        // Check that the Voronoi noise coordinates are within the expected range
        expect.int64(x).greaterOrEqual(-18432);
        expect.int64(x).lessOrEqual(18432);
        expect.int64(y).greaterOrEqual(-18432);
        expect.int64(y).lessOrEqual(18432);
        expect.int64(z).greaterOrEqual(-18432);
        expect.int64(z).lessOrEqual(18432);
      },
    );
  },
);
