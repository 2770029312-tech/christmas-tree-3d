# Christmas Tree 3D

A mobile WebGL version of the rotating Pygame Christmas tree in
`D:/Christmas-Tree-main/tree.py`.

The scene renders 26,200 particles for the tree, ground rings, sky, and heart.
It runs from one generated `index.html` file with Three.js bundled inline, so
the published page does not depend on a CDN or any external assets.

## Open

Open `index.html` directly, or use the GitHub Pages URL once published.

Drag to rotate the tree. Pinch on iPhone or use the mouse wheel to zoom.

## Rebuild

```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1
```

## Verify

```powershell
powershell -ExecutionPolicy Bypass -File .\smoke-test.ps1
powershell -ExecutionPolicy Bypass -File .\smoke-test.ps1 -Width 1280 -Height 900 -Scale 1 -Name desktop
```

The smoke test renders the page in headless Edge, rejects a blank or top-cropped
mobile scene, and confirms the renderer reaches its first frame.

## Credit

The original scene is `tree.py` by the repository owner. The bundled Three.js
runtime is r128 under the MIT license.
