import Nat32 "mo:base/Nat32";

module {
  public func lerp(part : Float, from : Float, to : Float) : Float {
    return from + part * (to - from);
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
