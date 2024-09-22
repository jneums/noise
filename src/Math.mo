import Nat64 "mo:base/Nat64";
import Nat32 "mo:base/Nat32";
import Int64 "mo:base/Int64";
import Int32 "mo:base/Int32";

module {
  public func lerp(part : Float, from : Float, to : Float) : Float {
    return from + part * (to - from);
  };

  public func uint64ToInt32(x : Nat64) : Int32 {
    let lower32Bits = Nat64.toNat32(Nat64.bitand(x, 0xFFFFFFFF));
    return Int32.fromNat32(lower32Bits);
  };

  public func uint64ToInt64(x : Nat64) : Int64 {
    return Int64.fromNat64(x);
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
