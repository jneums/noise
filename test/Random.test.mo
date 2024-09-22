import { test; suite; expect } "mo:test";
import Nat64 "mo:base/Nat64";
import Int64 "mo:base/Int64";
import Random "../src/Random";

suite(
  "Random Functions",
  func() {
    let seed : Nat64 = 1234567890123456789;
    let salt : Nat64 = 9876543210987654321;

    test(
      "mcStepSeed",
      func() {
        let result = Random.mcStepSeed(seed, salt);
        expect.nat64(result).equal(17492951551070516501);
      },
    );

    test(
      "xSetSeed",
      func() {
        let xoroshiro = Random.xSetSeed(seed);
        expect.nat64(xoroshiro.low).equal(8769092525673015319);
        expect.nat64(xoroshiro.high).equal(10965470254048619885);
      },
    );

    test(
      "xNextNat64",
      func() {
        var xoroshiro = Random.xSetSeed(seed);
        let first = Random.xNextNat64(xoroshiro);
        let second = Random.xNextNat64(xoroshiro);
        let third = Random.xNextNat64(xoroshiro);

        // Reset the seed and generate the sequence again
        xoroshiro := Random.xSetSeed(seed);
        expect.nat64(Random.xNextNat64(xoroshiro)).equal(first);
        expect.nat64(Random.xNextNat64(xoroshiro)).equal(second);
        expect.nat64(Random.xNextNat64(xoroshiro)).equal(third);
      },
    );

    test(
      "xNextNat32",
      func() {
        var xoroshiro = Random.xSetSeed(seed);
        let first = Random.xNextNat32(xoroshiro, 100);
        let second = Random.xNextNat32(xoroshiro, 100);
        let third = Random.xNextNat32(xoroshiro, 100);

        // Reset the seed and generate the sequence again
        xoroshiro := Random.xSetSeed(seed);
        expect.nat32(Random.xNextNat32(xoroshiro, 100)).equal(first);
        expect.nat32(Random.xNextNat32(xoroshiro, 100)).equal(second);
        expect.nat32(Random.xNextNat32(xoroshiro, 100)).equal(third);
      },
    );

    test(
      "xNextFloat sequence",
      func() {
        var xoroshiro = Random.xSetSeed(seed);
        let first = Random.xNextFloat(xoroshiro);
        assert first >= 0.0;
        assert first < 1.0;
        let second = Random.xNextFloat(xoroshiro);
        let third = Random.xNextFloat(xoroshiro);

        // Reset the seed and generate the sequence again
        xoroshiro := Random.xSetSeed(seed);
        assert (Random.xNextFloat(xoroshiro) == first);
        assert (Random.xNextFloat(xoroshiro) == second);
        assert (Random.xNextFloat(xoroshiro) == third);
      },
    );

    test(
      "nextNat32",
      func() {
        let result = Random.nextNat32(seed, 100);
        expect.nat32(result).lessOrEqual(100);
      },
    );

    test(
      "nextFloat",
      func() {
        let result = Random.nextFloat(seed);
        assert result >= 0.0;
        assert result < 1.0;
      },
    );

    test(
      "setAttemptSeed",
      func() {
        let cx : Int64 = 10;
        let cz : Int64 = 20;
        let result = Random.setAttemptSeed(seed, cx, cz);
        expect.nat64(result).notEqual(seed);
      },
    );

    test(
      "next",
      func() {
        let (newSeed, int) = Random.next(seed, 31);
        expect.nat64(newSeed).notEqual(seed);
        expect.nat32(int).lessOrEqual(2147483647); // 2^31 - 1
      },
    );

    test(
      "setSeed",
      func() {
        let result = Random.setSeed(seed);
        expect.nat64(result).notEqual(seed);
      },
    );

    test(
      "nextNat64",
      func() {
        let result = Random.nextNat64(seed);
        expect.nat64(result).notEqual(seed);
      },
    );

    test(
      "chunkGenerateRnd",
      func() {
        let chunkX : Int64 = 10;
        let chunkZ : Int64 = 20;
        let result = Random.chunkGenerateRnd(seed, chunkX, chunkZ);
        expect.nat64(result).notEqual(seed);
      },
    );

    test(
      "getVoronoiSHA",
      func() {
        let result = Random.getVoronoiSHA(seed);
        expect.nat64(result).notEqual(seed);
      },
    );

    // Additional tests for deterministic sequences
    test(
      "xNextNat sequence",
      func() {
        var xoroshiro = Random.xSetSeed(seed);
        let first = Random.xNextNat64(xoroshiro);
        let second = Random.xNextNat64(xoroshiro);
        let third = Random.xNextNat64(xoroshiro);

        // Reset the seed and generate the sequence again
        xoroshiro := Random.xSetSeed(seed);
        expect.nat64(Random.xNextNat64(xoroshiro)).equal(first);
        expect.nat64(Random.xNextNat64(xoroshiro)).equal(second);
        expect.nat64(Random.xNextNat64(xoroshiro)).equal(third);
      },
    );

    test(
      "xNextNat32 sequence",
      func() {
        var xoroshiro = Random.xSetSeed(seed);
        let first = Random.xNextNat32(xoroshiro, 100);
        let second = Random.xNextNat32(xoroshiro, 100);
        let third = Random.xNextNat32(xoroshiro, 100);

        // Reset the seed and generate the sequence again
        xoroshiro := Random.xSetSeed(seed);
        expect.nat32(Random.xNextNat32(xoroshiro, 100)).equal(first);
        expect.nat32(Random.xNextNat32(xoroshiro, 100)).equal(second);
        expect.nat32(Random.xNextNat32(xoroshiro, 100)).equal(third);
      },
    );

    test(
      "xNextFloat sequence",
      func() {
        var xoroshiro = Random.xSetSeed(seed);
        let first = Random.xNextFloat(xoroshiro);
        let second = Random.xNextFloat(xoroshiro);
        let third = Random.xNextFloat(xoroshiro);

        // Reset the seed and generate the sequence again
        xoroshiro := Random.xSetSeed(seed);
        assert (Random.xNextFloat(xoroshiro) == first);
        assert (Random.xNextFloat(xoroshiro) == second);
        assert (Random.xNextFloat(xoroshiro) == third);
      },
    );

    // Additional tests for edge cases and boundary values
    test(
      "xNextNat32 edge cases",
      func() {
        var xoroshiro = Random.xSetSeed(seed);
        let result1 = Random.xNextNat32(xoroshiro, 1);
        expect.nat32(result1).equal(0);

        let result2 = Random.xNextNat32(xoroshiro, 0xffffffff);
        expect.nat32(result2).lessOrEqual(0xffffffff);
      },
    );

    test(
      "nextNat32 edge cases",
      func() {
        let result1 = Random.nextNat32(seed, 1);
        expect.nat32(result1).equal(0);

        let result2 = Random.nextNat32(seed, 0xffffffff);
        expect.nat32(result2).lessOrEqual(0xffffffff);
      },
    );

    test(
      "nextFloat boundary values",
      func() {
        let result = Random.nextFloat(seed);
        assert result >= 0.0;
        assert result < 1.0;
      },
    );

    test(
      "xNextFloat boundary values",
      func() {
        var xoroshiro = Random.xSetSeed(seed);
        let result = Random.xNextFloat(xoroshiro);
        assert result >= 0.0;
        assert result < 1.0;
      },
    );
  },
);
