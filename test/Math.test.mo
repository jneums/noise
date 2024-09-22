import { test; suite; expect } "mo:test";
import Nat64 "mo:base/Nat64";
import { lerp; uint64ToInt32; uint64ToInt64; bswap32 } "../src/Math";

suite(
  "Math Functions",
  func() {
    test(
      "lerp",
      func() {
        assert lerp(0.5, 0.0, 10.0) == 5.0;
        assert lerp(0.0, 0.0, 10.0) == 0.0;
        assert lerp(1.0, 0.0, 10.0) == 10.0;
      },
    );

    test(
      "uint64ToInt32",
      func() {
        expect.int32(uint64ToInt32(0)).equal(0);
        expect.int32(uint64ToInt32(2147483647)).equal(2147483647);
        expect.int32(uint64ToInt32(2147483648)).equal(-2147483648);
        expect.int32(uint64ToInt32(Nat64.maximumValue)).equal(-1);
      },
    );

    test(
      "uint64ToInt64",
      func() {
        expect.int64(uint64ToInt64(0)).equal(0);
        expect.int64(uint64ToInt64(9223372036854775807)).equal(9223372036854775807);
        expect.int64(uint64ToInt64(9223372036854775808)).equal(-9223372036854775808);
        expect.int64(uint64ToInt64(Nat64.maximumValue)).equal(-1);
      },
    );

    test(
      "bswap32",
      func() {
        expect.nat32(bswap32(0x12345678)).equal(0x78563412);
        expect.nat32(bswap32(0x00000000)).equal(0x00000000);
        expect.nat32(bswap32(0xFFFFFFFF)).equal(0xFFFFFFFF);
        expect.nat32(bswap32(0xAABBCCDD)).equal(0xDDCCBBAA);
      },
    );
  },
);
