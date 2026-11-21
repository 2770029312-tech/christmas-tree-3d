# Christmas Tree Web Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the Pygame Christmas tree into a self-contained mobile web animation and publish it through GitHub Pages.

**Architecture:** One `index.html` bundles Three.js and all scene code. A single WebGL point cloud renders the tree, ground, stars, and heart; HTML/CSS overlays handle copy and snow. GitHub Pages serves the static file.

**Tech Stack:** HTML, CSS, JavaScript, Three.js r128, WebGL, GitHub Pages.

**Spec:** `docs/superpowers/specs/2026-11-21-christmas-tree-web-design.md`

## Global Constraints

- No external runtime assets, fonts, or CDN requests.
- Mobile-first portrait layout for iPhone and WeChat.
- Auto rotation plus drag rotation and pinch/wheel zoom.
- Public GitHub repository and public HTTPS Pages URL.

## Review Focus

- WebGL unavailable: show a short readable fallback instead of a blank page.
- Narrow portrait viewport: tree and copy must remain inside the visible area.
- High device pixel ratio: rendering must stay sharp without allocating an unbounded canvas.
- Touch gestures: page must not scroll or zoom while rotating the scene.
- Initial load before fonts or animation settle: the first frame must already contain visible particles.

---

### Task 1: Build the Self-Contained Mobile Scene

**Files:**
- Create: `index.html`
- Create: `README.md`
- Create: `.nojekyll`
- Test: `work/christmas-tree-web/smoke-test.ps1`

**Interfaces:**
- Consumes: visual parameters and scene behavior from `D:/Christmas-Tree-main/tree.py`.
- Produces: a static `index.html` that runs directly from a local file or static server.

- [ ] **Step 1: Add a smoke test script**

Use headless Edge to capture a 390x844 screenshot, assert the PNG exists and is larger than 10 KB, and fail if the HTML contains remote `http://` or `https://` script/style URLs.

- [ ] **Step 2: Run the smoke test and verify it fails before the page exists**

Run: `powershell -ExecutionPolicy Bypass -File smoke-test.ps1`
Expected: failure because `index.html` is missing.

- [ ] **Step 3: Implement the scene**

Add `index.html` with inlined Three.js, deterministic point generation, a responsive WebGL canvas, the copy overlay, snow, touch controls, resize handling, and a WebGL fallback.

- [ ] **Step 4: Run the smoke test and inspect the screenshot**

Run: `powershell -ExecutionPolicy Bypass -File smoke-test.ps1`
Expected: PASS and a nonblank mobile screenshot.

- [ ] **Step 5: Add publication notes**

Document the public URL, controls, and the source Pygame file in `README.md`. Add an empty `.nojekyll` file so GitHub Pages serves the root directly.

- [ ] **Step 6: Commit**

```bash
git add index.html README.md .nojekyll
git commit -m "feat: add mobile Christmas tree scene"
```

### Task 2: Publish and Verify GitHub Pages

**Files:**
- Modify: repository metadata only

**Interfaces:**
- Consumes: the committed static site from Task 1.
- Produces: a public `https://<owner>.github.io/<repo>/` URL.

- [ ] **Step 1: Create the public repository and push `main`**

Run: `gh repo create <repo> --public --source . --remote origin --push`
Expected: the repository is created and the local commit is pushed.

- [ ] **Step 2: Enable Pages from the root of `main`**

Use the GitHub API through `gh api` to configure `build_type=legacy` and `source.branch=main`, `source.path=/`.

- [ ] **Step 3: Wait for deployment and verify HTTP 200**

Poll the Pages URL until GitHub returns HTTP 200.

- [ ] **Step 4: Capture the published page at a mobile viewport**

Run the smoke test against the public URL and inspect the screenshot.

- [ ] **Step 5: Commit any deployment metadata**

No source change is required if deployment metadata is correct; otherwise commit the minimal fix and repeat verification.
