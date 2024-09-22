import { test; suite; expect } "mo:test";
import Nat64 "mo:base/Nat64";
import Int64 "mo:base/Int64";
import {
  mcStepSeed;
  xSetSeed;
  xNextNat;
  xNextInt;
  xNextFloat;
  nextInt;
  nextFloat;
  setAttemptSeed;
  next;
  setSeed;
  nextNat;
  chunkGenerateRnd;
  getVoronoiSHA;
} "../src/Random";

suite(
  "Random Functions",
  func() {
    let seed : Nat64 = 1234567890123456789;
    let salt : Nat64 = 9876543210987654321;

    test(
      "mcStepSeed",
      func() {
        let result = mcStepSeed(seed, salt);
        expect.nat64(result).equal(17492951551070516501);
      },
    );

    test(
      "xSetSeed",
      func() {
        let xoroshiro = xSetSeed(seed);
        expect.nat64(xoroshiro.low).equal(8769092525673015319);
        expect.nat64(xoroshiro.high).equal(10965470254048619885);
      },
    );

    test(
      "xNextNat",
      func() {
        var xoroshiro = xSetSeed(seed);
        let first = xNextNat(xoroshiro);
        let second = xNextNat(xoroshiro);
        let third = xNextNat(xoroshiro);

        // Reset the seed and generate the sequence again
        xoroshiro := xSetSeed(seed);
        expect.nat64(xNextNat(xoroshiro)).equal(first);
        expect.nat64(xNextNat(xoroshiro)).equal(second);
        expect.nat64(xNextNat(xoroshiro)).equal(third);
      },
    );

    test(
      "xNextInt",
      func() {
        var xoroshiro = xSetSeed(seed);
        let first = xNextInt(xoroshiro, 100);
        let second = xNextInt(xoroshiro, 100);
        let third = xNextInt(xoroshiro, 100);

        // Reset the seed and generate the sequence again
        xoroshiro := xSetSeed(seed);
        expect.nat32(xNextInt(xoroshiro, 100)).equal(first);
        expect.nat32(xNextInt(xoroshiro, 100)).equal(second);
        expect.nat32(xNextInt(xoroshiro, 100)).equal(third);
      },
    );

    test(
      "xNextFloat sequence",
      func() {
        var xoroshiro = xSetSeed(seed);
        let first = xNextFloat(xoroshiro);
        assert first >= 0.0;
        assert first < 1.0;
        let second = xNextFloat(xoroshiro);
        let third = xNextFloat(xoroshiro);

        // Reset the seed and generate the sequence again
        xoroshiro := xSetSeed(seed);
        assert (xNextFloat(xoroshiro) == first);
        assert (xNextFloat(xoroshiro) == second);
        assert (xNextFloat(xoroshiro) == third);
      },
    );

    test(
      "nextInt",
      func() {
        let result = nextInt(seed, 100);
        expect.nat32(result).lessOrEqual(100);
      },
    );

    test(
      "nextFloat",
      func() {
        let result = nextFloat(seed);
        assert result >= 0.0;
        assert result < 1.0;
      },
    );

    test(
      "setAttemptSeed",
      func() {
        let cx : Int64 = 10;
        let cz : Int64 = 20;
        let result = setAttemptSeed(seed, cx, cz);
        expect.nat64(result).notEqual(seed);
      },
    );

    test(
      "next",
      func() {
        let (newSeed, int) = next(seed, 31);
        expect.nat64(newSeed).notEqual(seed);
        expect.nat32(int).lessOrEqual(2147483647); // 2^31 - 1
      },
    );

    test(
      "setSeed",
      func() {
        let result = setSeed(seed);
        expect.nat64(result).notEqual(seed);
      },
    );

    test(
      "nextNat",
      func() {
        let result = nextNat(seed);
        expect.nat64(result).notEqual(seed);
      },
    );

    test(
      "chunkGenerateRnd",
      func() {
        let chunkX : Int64 = 10;
        let chunkZ : Int64 = 20;
        let result = chunkGenerateRnd(seed, chunkX, chunkZ);
        expect.nat64(result).notEqual(seed);
      },
    );

    test(
      "getVoronoiSHA",
      func() {
        let result = getVoronoiSHA(seed);
        expect.nat64(result).notEqual(seed);
      },
    );

    // Additional tests for deterministic sequences
    test(
      "xNextNat sequence",
      func() {
        var xoroshiro = xSetSeed(seed);
        let first = xNextNat(xoroshiro);
        let second = xNextNat(xoroshiro);
        let third = xNextNat(xoroshiro);

        // Reset the seed and generate the sequence again
        xoroshiro := xSetSeed(seed);
        expect.nat64(xNextNat(xoroshiro)).equal(first);
        expect.nat64(xNextNat(xoroshiro)).equal(second);
        expect.nat64(xNextNat(xoroshiro)).equal(third);
      },
    );

    test(
      "xNextInt sequence",
      func() {
        var xoroshiro = xSetSeed(seed);
        let first = xNextInt(xoroshiro, 100);
        let second = xNextInt(xoroshiro, 100);
        let third = xNextInt(xoroshiro, 100);

        // Reset the seed and generate the sequence again
        xoroshiro := xSetSeed(seed);
        expect.nat32(xNextInt(xoroshiro, 100)).equal(first);
        expect.nat32(xNextInt(xoroshiro, 100)).equal(second);
        expect.nat32(xNextInt(xoroshiro, 100)).equal(third);
      },
    );

    test(
      "xNextFloat sequence",
      func() {
        var xoroshiro = xSetSeed(seed);
        let first = xNextFloat(xoroshiro);
        let second = xNextFloat(xoroshiro);
        let third = xNextFloat(xoroshiro);

        // Reset the seed and generate the sequence again
        xoroshiro := xSetSeed(seed);
        assert (xNextFloat(xoroshiro) == first);
        assert (xNextFloat(xoroshiro) == second);
        assert (xNextFloat(xoroshiro) == third);
      },
    );

    // Additional tests for edge cases and boundary values
    test(
      "xNextInt edge cases",
      func() {
        var xoroshiro = xSetSeed(seed);
        let result1 = xNextInt(xoroshiro, 1);
        expect.nat32(result1).equal(0);

        let result2 = xNextInt(xoroshiro, 0xffffffff);
        expect.nat32(result2).lessOrEqual(0xffffffff);
      },
    );

    test(
      "nextInt edge cases",
      func() {
        let result1 = nextInt(seed, 1);
        expect.nat32(result1).equal(0);

        let result2 = nextInt(seed, 0xffffffff);
        expect.nat32(result2).lessOrEqual(0xffffffff);
      },
    );

    test(
      "nextFloat boundary values",
      func() {
        let result = nextFloat(seed);
        assert result >= 0.0;
        assert result < 1.0;
      },
    );

    test(
      "xNextFloat boundary values",
      func() {
        var xoroshiro = xSetSeed(seed);
        let result = xNextFloat(xoroshiro);
        assert result >= 0.0;
        assert result < 1.0;
      },
    );
  },
);
