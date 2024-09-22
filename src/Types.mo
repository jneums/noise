import Buffer "mo:base/Buffer";
module {
  /// A structure representing the state of the Xoroshiro random number generator.
  public type Xoroshiro = {
    var low : Nat64;
    var high : Nat64;
  };

  public type PerlinNoise = {
    var a : Float;
    var b : Float;
    var c : Float;
    var d : [var Nat32];
    var amplitude : Float;
    var lacunarity : Float;
  };

  public type DoublePerlinNoise = {
    var amplitude : Float;
    var octaveNoise1 : Octaves;
    var octaveNoise2 : Octaves;
  };

  public type Octaves = Buffer.Buffer<PerlinNoise>;

  public type Range = {
    var scale : Nat32;
    var x : Int32;
    var z : Int32;
    var y : Int32;
    var sx : Int32;
    var sz : Int32;
    var sy : Int32;
  };

};
