import { test; suite; expect } "mo:test";
import Nat64 "mo:base/Nat64";
import Float "mo:base/Float";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Text "mo:base/Text";
import Nat8 "mo:base/Nat8";
import Nat "mo:base/Nat";
import { xSetSeed } "../src/Random";
import {
  xPerlinInit;
  xOctaveInit;
  xDoublePerlinInit;
  samplePerlinNoise;
  sampleOctaves;
  sampleDoublePerlinNoise;
  getIndexedLerp;
  getVoronoiSrcRange;
  getVoronoiCell;
  voronoiAccess3D;
} "../src/Noise";
import T "../src/Types";

suite(
  "Noise Functions",
  func() {
    let seed : Nat64 = 1234567890123456789;

    test(
      "xPerlinInit",
      func() {
        let xoroshiro = xSetSeed(seed);
        let perlinNoise = xPerlinInit(xoroshiro);

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
        let xoroshiro = xSetSeed(seed);
        let amplitudes : [Float] = [1.0, 0.5, 0.25];
        let octaves = xOctaveInit(xoroshiro, amplitudes, -3, amplitudes.size(), 3);

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
        let xoroshiro = xSetSeed(seed);
        let amplitudes : [Float] = [1.0, 0.5, 0.25];
        let doublePerlinNoise = xDoublePerlinInit(xoroshiro, amplitudes, -3, amplitudes.size(), 3);

        // Check that the Double Perlin noise instance is initialized correctly
        assert doublePerlinNoise.amplitude != 0.0;
        expect.nat(doublePerlinNoise.octaveNoise1.size()).equal(2);
        expect.nat(doublePerlinNoise.octaveNoise2.size()).equal(1);
      },
    );

    test(
      "samplePerlinNoise",
      func() {
        let xoroshiro = xSetSeed(seed);
        let perlinNoise = xPerlinInit(xoroshiro);

        // Sample the Perlin noise at a given point
        let noiseValue = samplePerlinNoise(perlinNoise, 0.5, 0.5, 0.5, 0.0, 0.0);

        // Check that the noise value is within the expected range
        assert noiseValue >= -1.0;
        assert noiseValue <= 1.0;
      },
    );

    test(
      "sampleOctaves",
      func() {
        let xoroshiro = xSetSeed(seed);
        let amplitudes : [Float] = [1.0, 0.5, 0.25];
        let octaves = xOctaveInit(xoroshiro, amplitudes, 0, amplitudes.size(), 3);

        // Sample the Octave noise at a given point
        let noiseValue = sampleOctaves(octaves, 0.5, 0.5, 0.5);

        // Check that the noise value is within the expected range
        assert noiseValue >= -1.0;
        assert noiseValue <= 1.0;
      },
    );

    test(
      "sampleDoublePerlinNoise",
      func() {
        let xoroshiro = xSetSeed(seed);
        let amplitudes : [Float] = [1.0, 0.5, 0.25];
        let doublePerlinNoise = xDoublePerlinInit(xoroshiro, amplitudes, 0, amplitudes.size(), 3);

        // Sample the Double Perlin noise at a given point
        let noiseValue = sampleDoublePerlinNoise(doublePerlinNoise, 0.5, 0.5, 0.5);

        // Check that the noise value is within the expected range
        assert noiseValue >= -1.0;
        assert noiseValue <= 1.0;
      },
    );

    test(
      "getIndexedLerp",
      func() {
        // Test the getIndexedLerp function with various indices
        assert getIndexedLerp(0, 1.0, 2.0, 3.0) == 3.0;
        assert getIndexedLerp(1, 1.0, 2.0, 3.0) == 1.0;
        assert getIndexedLerp(2, 1.0, 2.0, 3.0) == -1.0;
        assert getIndexedLerp(3, 1.0, 2.0, 3.0) == -3.0;
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
        let srcRange = getVoronoiSrcRange(range);

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
        let (x, y, z) = getVoronoiCell(sha, 0, 0, 0);

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
        let (x, y, z) = voronoiAccess3D(sha, 0, 0, 0);

        // Check that the Voronoi noise coordinates are within the expected range
        expect.int64(x).greaterOrEqual(-18432);
        expect.int64(x).lessOrEqual(18432);
        expect.int64(y).greaterOrEqual(-18432);
        expect.int64(y).lessOrEqual(18432);
        expect.int64(z).greaterOrEqual(-18432);
        expect.int64(z).lessOrEqual(18432);
      },
    );

    // test(
    //   "generate2DNoiseMap",
    //   func() {
    //     let width = 50;
    //     let height = 50;
    //     let scale = 6.0;
    //     let seed : Nat64 = 1234567890123456789;

    //     let noiseMap = generate2DNoiseMap(width, height, scale, seed);

    //     // Check that the noise map has the correct dimensions
    //     expect.nat(noiseMap.size()).equal(width);
    //     expect.nat(noiseMap[0].size()).equal(height);

    //     // Optionally, print the noise map for visual inspection
    //     // printNoiseMap(noiseMap);
    //   },
    // );

    // test(
    //   "generateImageData",
    //   func() {
    //     let width = 50;
    //     let height = 50;
    //     let scale = 10.0;
    //     let seed : Nat64 = 1234567890123456789;

    //     let noiseMap = generate2DNoiseMap(width, height, scale, seed);
    //     let imageData = generateImageData(noiseMap);

    //     // Check that the image data has the correct dimensions
    //     expect.nat(imageData.size()).equal(width);
    //     expect.nat(imageData[0].size()).equal(height);

    //     // Optionally, print the image data for visual inspection
    //     // printImageData(imageData);
    //   },
    // );
  },
);
