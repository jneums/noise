import { test; suite; expect } "mo:test";
import Math "../src/Math";

suite(
  "Math Functions",
  func() {
    test(
      "lerp",
      func() {
        assert Math.lerp(0.5, 0.0, 10.0) == 5.0;
        assert Math.lerp(0.0, 0.0, 10.0) == 0.0;
        assert Math.lerp(1.0, 0.0, 10.0) == 10.0;
      },
    );

    test(
      "getIndexedLerp",
      func() {
        // Test the getIndexedLerp function with various indices
        assert Math.getIndexedLerp(0, 1.0, 2.0, 3.0) == 3.0;
        assert Math.getIndexedLerp(1, 1.0, 2.0, 3.0) == 1.0;
        assert Math.getIndexedLerp(2, 1.0, 2.0, 3.0) == -1.0;
        assert Math.getIndexedLerp(3, 1.0, 2.0, 3.0) == -3.0;
      },
    );

    test(
      "bswap32",
      func() {
        expect.nat32(Math.bswap32(0x12345678)).equal(0x78563412);
        expect.nat32(Math.bswap32(0x00000000)).equal(0x00000000);
        expect.nat32(Math.bswap32(0xFFFFFFFF)).equal(0xFFFFFFFF);
        expect.nat32(Math.bswap32(0xAABBCCDD)).equal(0xDDCCBBAA);
      },
    );
  },
);
