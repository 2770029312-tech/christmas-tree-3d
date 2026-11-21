# Christmas Tree Web Page Design

## Intent

The source `D:/Christmas-Tree-main/tree.py` is a desktop Pygame scene that cannot run inside WeChat on iPhone. The goal is a permanent public web page that reproduces the scene as an animated mobile experience and can be opened from a shared WeChat link.

## Goals

- Preserve the rotating particle tree, ground light rings, sky points, heart above the tree, foreground snow, and the "Merry Christmas" / "wyx" copy.
- Run as one self-contained HTML file with no CDN, font, or asset dependencies.
- Fit iPhone portrait screens and remain usable in the WeChat embedded browser.
- Support automatic rotation, drag rotation, and pinch/wheel zoom.
- Publish through GitHub Pages as a public HTTPS link.

## Non-Goals

- Pixel-identical parity with the Pygame renderer.
- Sound, accounts, analytics, or user controls.
- A native iOS or WeChat mini-program.

## Constraints

- Use WebGL through Three.js, bundled into the HTML so mobile rendering does not depend on external networks.
- Keep the public repository small and GitHub Pages compatible.
- Do not rely on local files or a development server after publication.

## Approaches Considered

1. Canvas 2D particle renderer. Familiar and simple, but tens of thousands of per-frame draw calls are likely to stutter on an iPhone.
2. Short video export. Smooth and universally playable, but loses interaction and is larger to share.
3. Three.js point cloud in WebGL. Chosen because it preserves the live rotation, renders all particles efficiently in one draw call, and supports touch interaction.

## Implementation Shape

- `index.html` contains the styles, inlined Three.js runtime, deterministic particle generation, rendering loop, snow overlay, and touch controls.
- The particle scene combines tree, ground, sky, and heart points into one colored geometry.
- A CSS overlay provides the original typography without loading an external font.
- GitHub Pages serves the repository root from the `main` branch.

## Acceptance

- The page loads without console errors in a desktop browser and at an iPhone-sized viewport.
- A screenshot shows a centered, nonblank Christmas tree with visible particles and foreground text.
- The published Pages URL returns HTTP 200 and the same page.
