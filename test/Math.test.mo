import { test; suite; expect } "mo:test";
import { lerp; bswap32 } "../src/Math";

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
