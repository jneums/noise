import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
import Int64 "mo:base/Int64";
import Int32 "mo:base/Int32";
import Float "mo:base/Float";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import { bswap32 } "../src/Math";
import T "Types";

/// A module for random number generation and seed manipulation.
module {

  /// Steps the seed using a given salt.
  ///
  /// Arguments
  /// - `seed`: The initial seed.
  /// - `salt`: The salt to use for stepping the seed.
  ///
  /// Returns
  /// A new seed value.
  public func mcStepSeed(seed : Nat64, salt : Nat64) : Nat64 {
    let m1 = Nat64.mulWrap(seed, 6364136223846793005);
    let m2 = Nat64.mulWrap(m1, seed);
    let a1 = Nat64.addWrap(m2, 1442695040888963407);

    return Nat64.addWrap(Nat64.mulWrap(seed, a1), salt);
  };

  /// Sets the seed for the Xoroshiro random number generator.
  ///
  /// Arguments
  /// - `seed`: The seed value to initialize the generator.
  ///
  /// Returns
  /// An initialized `Xoroshiro` state.
  public func xSetSeed(seed : Nat64) : T.Xoroshiro {
    let XL : Nat64 = 0x9e3779b97f4a7c15;
    let XH : Nat64 = 0x6a09e667f3bcc909;
    let A : Nat64 = 0xbf58476d1ce4e5b9;
    let B : Nat64 = 0x94d049bb133111eb;

    var l = Nat64.bitxor(seed, XH);
    var h = Nat64.addWrap(l, XL);

    l := Nat64.mulWrap(Nat64.bitxor(l, Nat64.bitshiftRight(l, 30)), A);
    h := Nat64.mulWrap(Nat64.bitxor(h, Nat64.bitshiftRight(h, 30)), A);
    l := Nat64.mulWrap(Nat64.bitxor(l, Nat64.bitshiftRight(l, 27)), B);
    h := Nat64.mulWrap(Nat64.bitxor(h, Nat64.bitshiftRight(h, 27)), B);
    l := Nat64.bitxor(l, Nat64.bitshiftRight(l, 31));
    h := Nat64.bitxor(h, Nat64.bitshiftRight(h, 31));

    return { var low = l; var high = h };
  };

  /// Generates the next nat value from the Xoroshiro state.
  ///
  /// Arguments
  /// - `xr`: The current state of the Xoroshiro generator.
  ///
  /// Returns
  /// A new nat value.
  public func xNextNat(xr : T.Xoroshiro) : Nat64 {
    let l = xr.low;
    let h = xr.high;
    let n = Nat64.addWrap(Nat64.bitrotLeft(Nat64.addWrap(l, h), 17), l);
    let xor = Nat64.bitxor(h, l);

    xr.low := Nat64.bitxor(Nat64.bitxor(Nat64.bitrotLeft(l, 49), xor), Nat64.bitshiftLeft(xor, 21));
    xr.high := Nat64.bitrotLeft(xor, 28);

    return n;
  };

  /// Generates the next integer value from the Xoroshiro state within a given range.
  ///
  /// Arguments
  /// - `state`: The current state of the Xoroshiro generator.
  /// - `bound`: The upper bound for the generated integer.
  ///
  /// Returns
  /// A new integer value within the specified range.
  public func xNextInt(state : T.Xoroshiro, bound : Nat32) : Nat32 {
    var r = Nat64.mulWrap(Nat64.bitand(xNextNat(state), 0xffffffff), Nat64.fromNat32(bound));
    if (Nat64.bitand(r, 0xffffffff) < Nat64.fromNat32(bound)) {
      while (Nat64.bitand(r, 0xffffffff) < Nat64.fromNat32(Nat32.subWrap(Nat32.bitnot(bound), 1)) % Nat64.fromNat32(bound)) {
        r := Nat64.mulWrap(Nat64.bitand(xNextNat(state), 0xffffffff), Nat64.fromNat32(bound));
      };
    };
    return Nat32.fromNat64(Nat64.bitshiftRight(r, 32));
  };

  /// Generates the next float value from the Xoroshiro state.
  ///
  /// Arguments
  /// - `state`: The current state of the Xoroshiro generator.
  ///
  /// Returns
  /// A new float value between 0.0 and 1.0.
  public func xNextFloat(state : T.Xoroshiro) : Float {
    return Float.fromInt64(Int64.fromNat64(xNextNat(state) >> 11)) * 1.1102230246251565e-16;
  };

  /// Generates the next integer value from a given seed within a specified range.
  ///
  /// Arguments
  /// - `seed`: The seed value.
  /// - `bound`: The upper bound for the generated integer.
  ///
  /// Returns
  /// A new integer value within the specified range.
  public func nextInt(seed : Nat64, bound : Nat32) : Nat32 {
    let m = Nat32.subWrap(bound, 1);
    var xSeed = seed;

    if (Nat32.bitand(m, bound) == 0) {
      let (newSeed, int) = next(xSeed, 31);
      xSeed := newSeed;
      let x = Nat32.mulWrap(bound, int);
      return Nat32.bitshiftRight(x, 31);
    };

    var bits : Nat32 = 0;
    var val : Nat32 = 0;

    loop {
      let (newSeed, int) = next(xSeed, 31);
      xSeed := newSeed;
      bits := int;
      val := Nat32.rem(bits, bound);
    } while (Nat32.subWrap(bits, val) + m < 0);

    return val;
  };

  /// Generates the next float value from a given seed.
  ///
  /// Arguments
  /// - `seed`: The seed value.
  ///
  /// Returns
  /// A new float value between 0.0 and 1.0.
  public func nextFloat(seed : Nat64) : Float {
    return Float.fromInt64(Int64.fromInt32(Int32.fromNat32(next(seed, 24).1))) / (Float.fromInt64(Int64.fromNat64(Nat64.bitshiftLeft(1, 24))));
  };

  /// Sets the attempt seed based on the initial seed and chunk coordinates.
  ///
  /// Arguments
  /// - `seed`: The initial seed.
  /// - `chunkX`: The chunk x-coordinate.
  /// - `chunkZ`: The chunk z-coordinate.
  ///
  /// Returns
  /// A new attempt seed.
  public func setAttemptSeed(seed : Nat64, chunkX : Int64, chunkZ : Int64) : Nat64 {
    var xSeed = Nat64.bitxor(seed, Nat64.bitxor(Nat64.bitshiftRight(Int64.toNat64(chunkX), 4), Nat64.bitshiftLeft(Nat64.bitshiftRight(Int64.toNat64(chunkZ), 4), 4)));
    xSeed := setSeed(xSeed);
    xSeed := next(xSeed, 31).0;
    return xSeed;
  };

  /// Generates the next value and updates the seed.
  ///
  /// Arguments
  /// - `seed`: The current seed.
  /// - `bits`: The number of bits for the generated value.
  ///
  /// Returns
  /// A tuple containing the new seed and the generated value.
  public func next(seed : Nat64, bits : Nat32) : (Nat64, Nat32) {
    let xSeed = Nat64.bitand(Nat64.addWrap(Nat64.mulWrap(seed, 0x5deece66d), 0xb), Nat64.subWrap(Nat64.bitshiftLeft(1, 48), 1));
    let int = Nat32.fromNat64(Nat64.bitshiftRight(xSeed, Nat32.toNat64(Nat32.sub(48, bits))));
    return (xSeed, int);
  };

  /// Sets the seed for the random number generator.
  ///
  /// Arguments
  /// - `seed`: The seed value.
  ///
  /// Returns
  /// A new seed value.
  public func setSeed(seed : Nat64) : Nat64 {
    return Nat64.bitand(Nat64.bitxor(seed, 0x5deece66d), Nat64.sub(Nat64.bitshiftLeft(1, 48), 1));
  };

  /// Generates the next nat value from a given seed.
  ///
  /// Arguments
  /// - `seed`: The seed value.
  ///
  /// Returns
  /// A new nat value.
  public func nextNat(seed : Nat64) : Nat64 {
    return Nat64.add(Nat64.bitshiftLeft(Nat64.fromNat32(next(seed, 32).1), 32), Nat64.fromNat32(next(seed, 32).1));
  };

  /// Generates a random value for chunk generation based on the seed and chunk coordinates.
  ///
  /// Arguments
  /// - `seed`: The initial seed.
  /// - `chunkX`: The chunk x-coordinate.
  /// - `chunkZ`: The chunk z-coordinate.
  ///
  /// Returns
  /// A new random value for chunk generation.
  public func chunkGenerateRnd(seed : Nat64, chunkX : Int64, chunkZ : Int64) : Nat64 {
    var rnd = setSeed(seed);

    rnd := Nat64.bitxor(
      Nat64.bitxor(
        Nat64.mulWrap(nextNat(rnd), Int64.toNat64(chunkX)),
        Nat64.mulWrap(nextNat(rnd), Int64.toNat64(chunkZ)),
      ),
      seed,
    );

    return setSeed(rnd);
  };

  /// Generates a Voronoi SHA value based on the seed.
  ///
  /// Arguments
  /// - `seed`: The seed value.
  ///
  /// Returns
  /// A new Voronoi SHA value.
  public func getVoronoiSHA(seed : Nat64) : Nat64 {
    let K : [Nat32] = [
      0x428a2f98,
      0x71374491,
      0xb5c0fbcf,
      0xe9b5dba5,
      0x3956c25b,
      0x59f111f1,
      0x923f82a4,
      0xab1c5ed5,
      0xd807aa98,
      0x12835b01,
      0x243185be,
      0x550c7dc3,
      0x72be5d74,
      0x80deb1fe,
      0x9bdc06a7,
      0xc19bf174,
      0xe49b69c1,
      0xefbe4786,
      0x0fc19dc6,
      0x240ca1cc,
      0x2de92c6f,
      0x4a7484aa,
      0x5cb0a9dc,
      0x76f988da,
      0x983e5152,
      0xa831c66d,
      0xb00327c8,
      0xbf597fc7,
      0xc6e00bf3,
      0xd5a79147,
      0x06ca6351,
      0x14292967,
      0x27b70a85,
      0x2e1b2138,
      0x4d2c6dfc,
      0x53380d13,
      0x650a7354,
      0x766a0abb,
      0x81c2c92e,
      0x92722c85,
      0xa2bfe8a1,
      0xa81a664b,
      0xc24b8b70,
      0xc76c51a3,
      0xd192e819,
      0xd6990624,
      0xf40e3585,
      0x106aa070,
      0x19a4c116,
      0x1e376c08,
      0x2748774c,
      0x34b0bcb5,
      0x391c0cb3,
      0x4ed8aa4a,
      0x5b9cca4f,
      0x682e6ff3,
      0x748f82ee,
      0x78a5636f,
      0x84c87814,
      0x8cc70208,
      0x90befffa,
      0xa4506ceb,
      0xbef9a3f7,
      0xc67178f2,
    ];
    let B : [Nat32] = [
      0x6a09e667,
      0xbb67ae85,
      0x3c6ef372,
      0xa54ff53a,
      0x510e527f,
      0x9b05688c,
      0x1f83d9ab,
      0x5be0cd19,
    ];

    var m : [var Nat32] = Array.init<Nat32>(64, 0);
    m[0] := bswap32(Nat32.fromNat64(Nat64.bitand(seed, Nat64.fromNat32(Nat32.maximumValue))));
    m[1] := bswap32(Nat32.fromNat64(Nat64.bitand(Nat64.bitshiftRight(seed, 32), Nat64.fromNat32(Nat32.maximumValue))));
    m[2] := 0x80000000;
    m[15] := 0x00000040;

    for (i in Iter.range(16, 63)) {
      m[i] := Nat32.addWrap(m[i - 7], m[i - 16]);
      var x = m[i - 15];
      m[i] := Nat32.addWrap(
        m[i],
        Nat32.bitxor(Nat32.bitxor(Nat32.bitrotRight(x, 7), Nat32.bitrotRight(x, 18)), Nat32.bitshiftRight(x, 3)),
      );
      x := m[i - 2];
      m[i] := Nat32.addWrap(
        m[i],
        Nat32.bitxor(Nat32.bitrotRight(x, 17), Nat32.bitxor(Nat32.bitrotRight(x, 19), Nat32.bitshiftRight(x, 10))),
      );
    };

    var a0 = B[0];
    var a1 = B[1];
    var a2 = B[2];
    var a3 = B[3];
    var a4 = B[4];
    var a5 = B[5];
    var a6 = B[6];
    var a7 = B[7];

    for (i in Iter.range(0, 63)) {
      var x = Nat32.addWrap(Nat32.addWrap(a7, K[i]), m[i]);
      x := Nat32.addWrap(x, Nat32.bitxor(Nat32.bitxor(Nat32.bitrotRight(a4, 6), Nat32.bitrotRight(a4, 11)), Nat32.bitrotRight(a4, 25)));
      x := Nat32.addWrap(x, Nat32.bitxor(Nat32.bitand(a4, a5), Nat32.bitand(Nat32.bitnot(a4), a6)));

      var y = Nat32.bitxor(Nat32.bitxor(Nat32.bitrotRight(a0, 2), Nat32.bitrotRight(a0, 13)), Nat32.bitrotRight(a0, 22));
      y := Nat32.addWrap(y, Nat32.bitxor(Nat32.bitxor(Nat32.bitand(a0, a1), Nat32.bitand(a0, a2)), Nat32.bitand(a1, a2)));

      a7 := a6;
      a6 := a5;
      a5 := a4;
      a4 := Nat32.addWrap(a3, x);
      a3 := a2;
      a2 := a1;
      a1 := a0;
      a0 := Nat32.addWrap(x, y);
    };

    a0 := Nat32.addWrap(a0, B[0]);
    a1 := Nat32.addWrap(a1, B[1]);

    return Nat64.bitor(Nat64.fromNat32(bswap32(a0)), Nat64.bitshiftLeft(Nat64.fromNat32(bswap32(a1)), 32));
  };
};
