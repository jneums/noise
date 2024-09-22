import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
import Int64 "mo:base/Int64";
import Int32 "mo:base/Int32";
import Float "mo:base/Float";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Random "Random";
import Math "Math";
import T "Types";

module {
  /// Initializes a Perlin noise generator with a given Xoroshiro state.
  ///
  /// Arguments
  /// - `xr`: The current state of the Xoroshiro generator.
  ///
  /// Returns
  /// A new PerlinNoise instance.
  public func xPerlinInit(xr : T.Xoroshiro) : T.PerlinNoise {
    let noise : T.PerlinNoise = {
      var a = Random.xNextFloat(xr) * 256.0;
      var b = Random.xNextFloat(xr) * 256.0;
      var c = Random.xNextFloat(xr) * 256.0;
      var d = Array.init<Nat32>(512, 0);
      var amplitude = 1.0;
      var lacunarity = 1.0;
    };

    for (i in Iter.range(0, 255)) {
      noise.d[i] := Nat32.fromNat(i);
    };

    for (i in Iter.range(0, 255)) {
      let i32 = Nat32.fromNat(i);
      let j = Nat32.toNat(Random.xNextNat32(xr, 256 - i32) + i32);
      let n = noise.d[i];
      noise.d[i] := noise.d[j];
      noise.d[j] := n;
      noise.d[i + 256] := noise.d[i];
    };

    return noise;
  };

  /// Initializes an Octave noise generator with a given Xoroshiro state and amplitudes.
  ///
  /// Arguments
  /// - `xr`: The current state of the Xoroshiro generator.
  /// - `amplitudes`: An array of amplitude values for each octave.
  /// - `omin`: The minimum octave index.
  /// - `lelength`: The length of the amplitude array.
  /// - `nmax`: The maximum number of octaves.
  ///
  /// Returns
  /// A new Octaves instance.
  public func xOctaveInit(
    xr : T.Xoroshiro,
    amplitudes : [Float],
    omin : Int,
    lelength : Nat,
    nmax : Nat32,
  ) : T.Octaves {
    let octaves = Buffer.Buffer<T.PerlinNoise>(lelength);

    let md5_octave_n = [
      (0xb198de63a8012672, 0x7b84cad43ef7b5a8),
      (0x0fd787bfbc403ec3, 0x74a4a31ca21b48b8),
      (0x36d326eed40efeb2, 0x5be9ce18223c636a),
      (0x082fe255f8be6631, 0x4e96119e22dedc81),
      (0x0ef68ec68504005e, 0x48b6bf93a2789640),
      (0xf11268128982754f, 0x257a1d670430b0aa),
      (0xe51c98ce7d1de664, 0x5f9478a733040c45),
      (0x6d7b49e7e429850a, 0x2e3063c622a24777),
      (0xbd90d5377ba1b762, 0xc07317d419a7548d),
      (0x53d39c6752dac858, 0xbcd1c5a80ab65b3e),
      (0xb4a24d7a84e7677b, 0x023ff9668e89b5c4),
      (0xdffa22b534c5f608, 0xb9b67517d3665ca9),
      (0xd50708086cef4d7c, 0x6e1651ecc7f43309),
    ];

    let lacuna_ini = [
      1.0,
      0.5,
      0.25,
      1.0 / 8.0,
      1.0 / 16.0,
      1.0 / 32.0,
      1.0 / 64.0,
      1.0 / 128.0,
      1.0 / 256.0,
      1.0 / 512.0,
      1.0 / 1024.0,
      1.0 / 2048.0,
      1.0 / 4096.0,
    ];

    let persist_ini = [
      0.0,
      1.0,
      2.0 / 3.0,
      4.0 / 7.0,
      8.0 / 15.0,
      16.0 / 31.0,
      32.0 / 63.0,
      64.0 / 127.0,
      128.0 / 255.0,
      256.0 / 511.0,
    ];

    var lacuna = lacuna_ini[Int.abs(omin)];
    var persist = persist_ini[lelength];
    let xLow = Random.xNextNat64(xr);
    let xHigh = Random.xNextNat64(xr);
    var n : Nat32 = 0;

    label iter for (i in Iter.range(0, lelength - 1)) {
      if (n == nmax) break iter;
      if (amplitudes[i] == 0.0) continue iter;

      let index = 12 + omin + i;
      if (index >= md5_octave_n.size()) break iter;

      let pxr = {
        var low = Nat64.bitxor(xLow, Nat64.fromNat(md5_octave_n[Int.abs(index)].0));
        var high = Nat64.bitxor(xHigh, Nat64.fromNat(md5_octave_n[Int.abs(index)].1));
      };
      let perlinNoise = xPerlinInit(pxr);

      perlinNoise.amplitude := amplitudes[i] * persist;
      perlinNoise.lacunarity := lacuna;
      octaves.add(perlinNoise);
      n += 1;
      lacuna *= 2.0;
      persist *= 0.5;
    };

    return octaves;
  };

  /// Initializes a Double Perlin noise generator with a given Xoroshiro state and amplitudes.
  ///
  /// Arguments
  /// - `xr`: The current state of the Xoroshiro generator.
  /// - `amplitudes`: An array of amplitude values for each octave.
  /// - `omin`: The minimum octave index.
  /// - `length`: The length of the amplitude array.
  /// - `nmax`: The maximum number of octaves.
  ///
  /// Returns
  /// A new DoublePerlinNoise instance.
  public func xDoublePerlinInit(
    xr : T.Xoroshiro,
    amplitudes : [Float],
    omin : Int,
    length : Nat,
    nmax : Nat32,
  ) : T.DoublePerlinNoise {
    var _length = length;

    let noise = {
      var amplitude = 0.0;
      var octaveNoise1 = xOctaveInit(xr, amplitudes, omin, length, 0);
      var octaveNoise2 = xOctaveInit(xr, amplitudes, omin, length, 0);
    };

    var n = 0;
    var na : Int32 = -1;
    var nb : Int32 = -1;

    if (nmax > 0) {
      na := Int32.bitshiftRight(Int32.fromNat32(nmax) + 1, 1);
      nb := Int32.fromNat32(nmax) - na;
    };

    noise.octaveNoise1 := xOctaveInit(xr, amplitudes, omin, length, Int32.toNat32(na));
    n += noise.octaveNoise1.size();

    noise.octaveNoise2 := xOctaveInit(xr, amplitudes, omin, length, Int32.toNat32(nb));
    n += noise.octaveNoise2.size();

    for (i in Iter.revRange(_length - 1, 0)) {
      if (amplitudes[Int.abs(i)] == 0.0) _length -= 1;
    };

    for (i in Iter.range(0, _length - 1)) {
      if (amplitudes[i] == 0.0) _length -= 1;
    };

    let amp_ini = [
      0.0,
      5.0 / 6.0,
      10.0 / 9.0,
      15.0 / 12.0,
      20.0 / 15.0,
      25.0 / 18.0,
      30.0 / 21.0,
      35.0 / 24.0,
      40.0 / 27.0,
      45.0 / 30.0,
    ];

    noise.amplitude := amp_ini[_length];
    return noise;
  };

  /// Samples the Double Perlin noise at a given point.
  ///
  /// Arguments
  /// - `noise`: The DoublePerlinNoise instance.
  /// - `x`: The x-coordinate.
  /// - `y`: The y-coordinate.
  /// - `z`: The z-coordinate.
  ///
  /// Returns
  /// The sampled noise value.
  public func sampleDoublePerlinNoise(
    noise : T.DoublePerlinNoise,
    x : Float,
    y : Float,
    z : Float,
  ) : Float {
    let f = 337.0 / 331.0;
    var v = 0.0;

    v += sampleOctaves(noise.octaveNoise1, x, y, z);
    v += sampleOctaves(noise.octaveNoise2, x * f, y * f, z * f);

    return v * noise.amplitude;
  };

  /// Samples the Octave noise at a given point.
  ///
  /// Arguments
  /// - `noise`: The Octaves instance.
  /// - `x`: The x-coordinate.
  /// - `y`: The y-coordinate.
  /// - `z`: The z-coordinate.
  ///
  /// Returns
  /// The sampled noise value.
  public func sampleOctaves(noise : T.Octaves, x : Float, y : Float, z : Float) : Float {
    var v = 0.0;

    for (i in Iter.range(0, noise.size() - 1)) {
      let p = noise.get(i);
      let lf = p.lacunarity;
      let ax = x * lf;
      let ay = y * lf;
      let az = z * lf;
      let pv = samplePerlinNoise(p, ax, ay, az, 0.0, 0.0);
      v += p.amplitude * pv;
    };

    return v;
  };

  /// Samples the Perlin noise at a given point.
  ///
  /// Arguments
  /// - `noise`: The PerlinNoise instance.
  /// - `d1`: The first dimension value.
  /// - `d2`: The second dimension value.
  /// - `d3`: The third dimension value.
  /// - `yamp`: The y-amplitude value.
  /// - `ymin`: The minimum y-value.
  ///
  /// Returns
  /// The sampled noise value.
  public func samplePerlinNoise(
    noise : T.PerlinNoise,
    d1 : Float,
    d2 : Float,
    d3 : Float,
    yamp : Float,
    ymin : Float,
  ) : Float {
    var _d1 = d1 + noise.a;
    var _d2 = d2 + noise.b;
    var _d3 = d3 + noise.c;
    let idx = noise.d;
    let i1 = Float.floor(_d1);
    let i2 = Float.floor(_d2);
    let i3 = Float.floor(_d3);
    _d1 -= i1;
    _d2 -= i2;
    _d3 -= i3;
    let t1 = _d1 * _d1 * _d1 * (_d1 * (_d1 * 6.0 - 15.0) + 10.0);
    let t2 = _d2 * _d2 * _d2 * (_d2 * (_d2 * 6.0 - 15.0) + 10.0);
    let t3 = _d3 * _d3 * _d3 * (_d3 * (_d3 * 6.0 - 15.0) + 10.0);

    if (yamp != 0.0) {
      let yclamp = if (ymin < _d2) ymin else _d2;
      _d2 -= Float.floor(yclamp / yamp) * yamp;
    };

    let i = Int32.bitand(Int32.fromInt64(Float.toInt64(i1)), 0xff);
    let j = Int32.bitand(Int32.fromInt64(Float.toInt64(i2)), 0xff);
    let k = Int32.bitand(Int32.fromInt64(Float.toInt64(i3)), 0xff);

    let a1 = idx[Nat32.toNat(Int32.toNat32(i))] + Int32.toNat32(j);
    let b1 = idx[Nat32.toNat(Int32.toNat32(i)) + 1] + Int32.toNat32(j);

    let a2 = idx[Nat32.toNat(a1)] + Int32.toNat32(k);
    let a3 = idx[Nat32.toNat(a1) + 1] + Int32.toNat32(k);
    let b2 = idx[Nat32.toNat(b1)] + Int32.toNat32(k);
    let b3 = idx[Nat32.toNat(b1) + 1] + Int32.toNat32(k);

    var l1 = Math.getIndexedLerp(idx[Nat32.toNat(a2)], _d1, _d2, _d3);
    var l2 = Math.getIndexedLerp(idx[Nat32.toNat(b2)], _d1 - 1.0, _d2, _d3);
    var l3 = Math.getIndexedLerp(idx[Nat32.toNat(a3)], _d1, _d2 - 1.0, _d3);
    var l4 = Math.getIndexedLerp(idx[Nat32.toNat(b3)], _d1 - 1.0, _d2 - 1.0, _d3);
    var l5 = Math.getIndexedLerp(idx[Nat32.toNat(a2) + 1], _d1, _d2, _d3 - 1.0);
    var l6 = Math.getIndexedLerp(idx[Nat32.toNat(b2) + 1], _d1 - 1.0, _d2, _d3 - 1.0);
    var l7 = Math.getIndexedLerp(idx[Nat32.toNat(a3) + 1], _d1, _d2 - 1.0, _d3 - 1.0);
    var l8 = Math.getIndexedLerp(idx[Nat32.toNat(b3) + 1], _d1 - 1.0, _d2 - 1.0, _d3 - 1.0);

    l1 := Math.lerp(t1, l1, l2);
    l3 := Math.lerp(t1, l3, l4);
    l5 := Math.lerp(t1, l5, l6);
    l7 := Math.lerp(t1, l7, l8);

    l1 := Math.lerp(t2, l1, l3);
    l5 := Math.lerp(t2, l5, l7);

    let result = Math.lerp(t3, l1, l5);

    return result;
  };

  /// Computes the source range for Voronoi noise.
  ///
  /// Arguments
  /// - `r`: The input range.
  ///
  /// Returns
  /// The computed source range.
  public func getVoronoiSrcRange(r : T.Range) : T.Range {
    assert (r.scale == 1);

    let x = r.x - 2;
    let z = r.z - 2;
    let s : T.Range = {
      var scale = 4;
      var x = Int32.bitshiftRight(x, 2);
      var z = Int32.bitshiftRight(z, 2);
      var sx = Int32.bitshiftRight(r.x + r.sx - 2, 2) - Int32.bitshiftRight(r.x - 2, 2) + 2;
      var sz = Int32.bitshiftRight(r.z + r.sz - 2, 2) - Int32.bitshiftRight(r.z - 2, 2) + 2;
      var y = 0;
      var sy = 1;
    };

    if (r.sy < 1) {
      s.y := 0;
      s.sy := 0;
    } else {
      let ty = r.y - 2;
      s.y := Int32.bitshiftRight(ty, 2);
      s.sy := Int32.bitshiftRight(ty + r.sy, 2) - s.y + 2;
    };

    return s;
  };

  /// Computes the Voronoi cell for given coordinates and a seed.
  ///
  /// Arguments
  /// - `sha`: The seed value.
  /// - `a`: The x-coordinate.
  /// - `b`: The y-coordinate.
  /// - `c`: The z-coordinate.
  ///
  /// Returns
  /// A tuple containing the x, y, and z coordinates of the Voronoi cell.
  public func getVoronoiCell(
    sha : Nat64,
    a : Int64,
    b : Int64,
    c : Int64,
  ) : (Int64, Int64, Int64) {
    var s = sha;

    for (i in Iter.range(0, 1)) {
      s := Random.mcStepSeed(s, Int64.toNat64(a));
      s := Random.mcStepSeed(s, Int64.toNat64(b));
      s := Random.mcStepSeed(s, Int64.toNat64(c));
    };

    let x = (Int64.fromNat64(Nat64.bitshiftRight(s, 24)) & 1023 - 512) * 36;
    s := Random.mcStepSeed(s, sha);
    let y = (Int64.fromNat64(Nat64.bitshiftRight(s, 24)) & 1023 - 512) * 36;
    s := Random.mcStepSeed(s, sha);
    let z = (Int64.fromNat64(Nat64.bitshiftRight(s, 24)) & 1023 - 512) * 36;

    return (x, y, z);
  };

  /// Accesses the 3D Voronoi noise for given coordinates and a seed.
  ///
  /// Arguments
  /// - `sha`: The seed value.
  /// - `x`: The x-coordinate.
  /// - `y`: The y-coordinate.
  /// - `z`: The z-coordinate.
  ///
  /// Returns
  /// A tuple containing the x, y, and z coordinates of the Voronoi noise.
  public func voronoiAccess3D(
    sha : Nat64,
    x : Int32,
    y : Int32,
    z : Int32,
  ) : (Int64, Int64, Int64) {
    var _x = x - 2;
    var _y = y - 2;
    var _z = z - 2;

    let pX = Int32.bitshiftRight(_x, 2);
    let pY = Int32.bitshiftRight(_y, 2);
    let pZ = Int32.bitshiftRight(_z, 2);

    let dx = (_x & 3) * 10240;
    let dy = (_y & 3) * 10240;
    let dz = (_z & 3) * 10240;

    var ax : Int64 = 0;
    var ay : Int64 = 0;
    var az : Int64 = 0;
    var dmin = Nat64.maximumValue;

    for (i in Iter.range(0, 7)) {
      let bx : Int64 = if (Int64.fromNat64(Nat64.fromNat(i)) & 4 != 0) 1 else 0;
      let by : Int64 = if (Int64.fromNat64(Nat64.fromNat(i)) & 2 != 0) 1 else 0;
      let bz : Int64 = if (Int64.fromNat64(Nat64.fromNat(i)) & 1 != 0) 1 else 0;
      let cx : Int64 = Int32.toInt64(pX) + bx;
      let cy : Int64 = Int32.toInt64(pY) + by;
      let cz : Int64 = Int32.toInt64(pZ) + bz;

      let (rx, ry, rz) = getVoronoiCell(sha, cx, cy, cz);

      var _rx = rx;
      var _ry = ry;
      var _rz = rz;

      _rx := _rx + Int32.toInt64(dx) - 40 * 1024 * bx;
      _ry := _ry + Int32.toInt64(dy) - 40 * 1024 * by;
      _rz := _rz + Int32.toInt64(dz) - 40 * 1024 * bz;

      let d = _rx * _rx + _ry * _ry + _rz * _rz;
      if (d < Int64.fromNat64(dmin)) {
        ax := cx;
        ay := cy;
        az := cz;
      };
    };

    return (ax, ay, az);
  };
};
