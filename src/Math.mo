import Nat32 "mo:base/Nat32";

module {
  public func lerp(part : Float, from : Float, to : Float) : Float {
    return from + part * (to - from);
  };

  /// Computes the indexed linear interpolation for given values.
  ///
  /// Arguments
  /// - `idx`: The index value.
  /// - `a`: The first value.
  /// - `b`: The second value.
  /// - `c`: The third value.
  ///
  /// Returns
  /// The interpolated value.
  public func getIndexedLerp(idx : Nat32, a : Float, b : Float, c : Float) : Float {
    switch (idx & 0xf) {
      case (0) {
        return a + b;
      };
      case (1) {
        return -a + b;
      };
      case 2 {
        return a - b;
      };
      case 3 {
        return -a - b;
      };
      case 4 {
        return a + c;
      };
      case 5 {
        return -a + c;
      };
      case 6 {
        return a - c;
      };
      case 7 {
        return -a - c;
      };
      case 8 {
        return b + c;
      };
      case 9 {
        return -b + c;
      };
      case 10 {
        return b - c;
      };
      case 11 {
        return -b - c;
      };
      case 12 {
        return a + b;
      };
      case 13 {
        return -b + c;
      };
      case 14 {
        return -a + b;
      };
      case 15 {
        return -b - c;
      };
      case (_) {
        return 0.0;
      };
    };
  };

  public func bswap32(n : Nat32) : Nat32 {
    return Nat32.bitor(
      Nat32.bitor(
        Nat32.bitor(
          Nat32.bitshiftRight(Nat32.bitand(n, 0xff000000), 24),
          Nat32.bitshiftRight(Nat32.bitand(n, 0x00ff0000), 8),
        ),
        Nat32.bitshiftLeft(Nat32.bitand(n, 0x0000ff00), 8),
      ),
      Nat32.bitshiftLeft(Nat32.bitand(n, 0x000000ff), 24),
    );
  };
};
