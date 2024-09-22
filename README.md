# Noise

[![mops](https://oknww-riaaa-aaaam-qaf6a-cai.raw.ic0.app/badge/mops/noise)](https://mops.one/noise) [![documentation](https://oknww-riaaa-aaaam-qaf6a-cai.raw.ic0.app/badge/documentation/noise)](https://mops.one/noise/docs)

## Overview

Noise is a library for generating Perlin noise in Motoko. It is designed to be simple to use and easy to integrate into your existing projects.

You can use Noise to generate 2D or 3D noise maps, which can be used for various applications such as terrain generation, procedural textures, and more.

## Usage

### Install with mops

You can install Noise using the mops package manager. To install Noise, run the following command:

```sh
mops add noise
```

### Live Demo

The live demo is available at [https://fh2cu-qyaaa-aaaai-qpihq-cai.icp0.io/](https://fh2cu-qyaaa-aaaai-qpihq-cai.icp0.io/).

### Full Example

Here is a full example of how to use Noise to generate a noise map and convert it to image data. In this example, we define functions to generate the noise map and image data, and then render the image data using a canvas in a React app.

```motoko
// Utils.mo
import Random "mo:noise/Random";
import Noise "mo:noise/Noise";
import T "Types";

module {
  public func generateNoiseMap(
    width : Nat,
    height : Nat,
    scale : Float,
    seed : Nat64,
  ) : [var Float] {
    let xoroshiro = Random.xSetSeed(seed);
    let perlinNoise = Noise.xPerlinInit(xoroshiro);

    var noiseMap = Array.init<Float>(width * height, 0.0);

    for (x in Iter.range(0, width - 1)) {
      for (y in Iter.range(0, height - 1)) {
        let nx = Float.fromInt(x) / scale;
        let ny = Float.fromInt(y) / scale;
        let noiseValue = Noise.samplePerlinNoise(perlinNoise, nx, ny, 0.0, 0.0, 0.0);
        let index = y * width + x;
        noiseMap[index] := noiseValue;
      };
    };

    return noiseMap;
  };

  public func generateImageData(noiseMap : [var Float], width : Nat, height : Nat) : [Nat8] {
    var imageData = Array.init<Nat8>(width * height, 0);

    for (x in Iter.range(0, width - 1)) {
      for (y in Iter.range(0, height - 1)) {
        let index = y * width + x;
        let normalizedValue = (noiseMap[index] + 1.0) / 2.0 * 255.0; // Map from [-1, 1] to [0, 255]
        imageData[index] := Nat8.fromNat(Int.abs(Float.toInt(Float.nearest(normalizedValue))));
      };
    };

    return Array.freeze(imageData);
  };
}
```

```motoko
// main.mo
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import Utils "Utils";

actor {
  public query func generate(seed : Nat64) : async [Nat8] {
    let width : Nat = 854;
    let height : Nat = 480;
    let scale : Float = 25.0;

    let noiseMap = Utils.generateNoiseMap(width, height, scale, seed);
    let imageData = Utils.generateImageData(noiseMap, width, height);

    return imageData;
  };
};
```

### React App Example

Here is an example of how to use the generated image data in a React app to render the noise map using a canvas:

```tsx
import { useState, useEffect, useRef } from 'react';
import { noise_maps_backend } from 'declarations/noise-maps-backend';

const width = 854; // Set the width of the noise map
const height = 480; // Set the height of the noise map

function App() {
  const [noiseMap, setNoiseMap] = useState();
  const [seed, setSeed] = useState(0);
  const canvasRef = useRef(null);

  function handleNext() {
    setSeed(seed + 1);
    noise_maps_backend.greet(seed + 1).then((noiseMap) => {
      setNoiseMap(new Uint8Array(noiseMap));
    });
    return false;
  }

  function handlePrevious() {
    setSeed(seed - 1);
    noise_maps_backend.greet(seed - 1).then((noiseMap) => {
      setNoiseMap(new Uint8Array(noiseMap));
    });
    return false;
  }

  useEffect(() => {
    if (noiseMap && canvasRef.current) {
      const canvas = canvasRef.current;
      const ctx = canvas.getContext('2d');
      if (ctx) {
        const imageData = ctx.createImageData(width, height);
        for (let i = 0; i < noiseMap.length; i++) {
          const value = noiseMap[i];
          imageData.data[i * 4] = value; // Red
          imageData.data[i * 4 + 1] = value; // Green
          imageData.data[i * 4 + 2] = value; // Blue
          imageData.data[i * 4 + 3] = 255; // Alpha
        }
        ctx.putImageData(imageData, 0, 0);
      }
    } else {
      handleNext();
    }
  }, [noiseMap]);

  return (
    <main>
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          maxWidth: '800px',
          margin: ' 32px auto',
          gap: '24px',
        }}>
        <img src="/logo2.svg" alt="DFINITY logo" />

        <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          <form action="#">
            <label htmlFor="seed">Enter your seed: &nbsp;</label>
            <input
              id="seed"
              alt="Seed"
              value={seed}
              onChange={(e) => setSeed(e.target.value)}
            />
            <div style={{ display: 'flex', gap: '8px' }}>
              <button onClick={handlePrevious}>Previous</button>
              <button onClick={handleNext}>Next</button>
            </div>
          </form>

          <div style={{ display: 'flex', flexDirection: 'column' }}>
            <canvas ref={canvasRef} width={width} height={height}></canvas>
            <a
              href="https://en.wikipedia.org/wiki/Perlin_noise"
              rel="noreferrer"
              target="_blank">
              <p style={{ fontSize: '1rem', textAlign: 'center' }}>
                Perlin Noise - Wikipedia
              </p>
            </a>
          </div>
        </div>
      </div>
    </main>
  );
}

export default App;
```
