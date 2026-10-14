# Mind Palace Dust Hood (prototype)

UNPRINTED PROTOTYPE. Slicing is in progress; not printed, airflow tested or fit tested. See [slicing progress](docs/slicing-progress.md) and [testing procedure](docs/testing.md).

- Cold, nonmetal dust only. NOT validated for metal sharpening, hot sparks or mixed metal/combustible dust.
- User tests required before relying on it. Do not start a print remotely.
- MakerWorld publication is gated on a physical print + test + permission checks.
- Inspired by a restricted MakerWorld model (see `docs/source-and-status.md`). Geometry here is original; only functional hose dimensions were reproduced. Nothing was imported.

`cad/mind-palace-dust-hood-incomplete.f3d` is an old Fusion checkpoint, kept untouched.

## Design

Nominal exterior 246 W x 240 D x 240 H. One upright open-front tub (3 mm), separate roof (3 mm), five removable 2 mm liners floating 10 mm inside the shell.

- Gaps behind the liners are one connected air volume ending in the rear chamber and the hose hole. Nothing is a blind pocket.
- 16 rounded 6x20 slots: floor 4, rear 4, sides 3 each, roof 2. All start >= 120 mm from the front.
- Front of the chambers is closed by a U frame on the tub (floor + both sides) and a skirt on the roof (top). Slide clearance is 0.3 mm, so a thin slit remains; seal it with removable tape before capture tests.
- Liners are plain plates held by M3x8 onto sparse nut posts on the shell (4 per liner). Nut sits `cap` (1 mm) under the post tip in a side-slot pocket.
- Right and left side liners are the same part (`side_liner`, print 2).
- Sideways posts (liner posts on side and rear walls, adapter posts) are teardrop sections PLUS a 3 mm wide 45 degree underside gusset back to the shell, so the lowest edge is not a ~10 mm unsupported cantilever. Roof bosses are wedges with the same 45 degree underside. The gussets stay inside the 10 mm chamber, below the liner face, and clear the liners (pairwise overlap check below). The nut slot opens toward +X/local side, away from the gusset, so nut loading is unchanged. No supports intended, still unvalidated in a slicer.
- Roof posts and floor posts are plain vertical cylinders (no gusset needed).
- Roof: 8 M3x8 into wedge bosses on both side walls and the rear wall, plus sparse locating tabs.
- Hose adapter is separate: flange on the rear wall, 4x M3x16 from outside into nut posts in the rear chamber.

### Hose socket (functional dims from `docs/source-and-status.md`)

- Bore 32.10, straight 39 mm, then 1 mm radius INTERNAL ROUND (not a chamfer) to a 34.10 mouth. Total insertion 40 mm. OD 39.80.
- Throat 25 mm (source measured radius 12.5 at the shoulder), used as the insertion stop and the rear wall hole.
- RESTRICTION: 25 mm is ~61% of the bore area. Its airflow effect is unvalidated.
- Dimensions are the nominal source values. No printer/material compensation is applied. If the fit coupon says it is tight or loose, that is a deliberate revision: change the socket values and the socket assertions in `cad/dust-hood.scad` together.

## Supported envelope (not arbitrarily parametric)

The parameters are named, but slot rows, screw rows, roof screw positions, tabs and the adapter/hose layout are hardcoded lists tuned for the nominal 246 x 240 x 240 shell. Assertions enforce only: W 241..246, D 235..246, H 235..245 (bed margin caps W and D at 246), wall/roof 2..4 mm, liner 1.6..2.4 mm, chamber 8..12 mm, positive clearances, and the screw stacks. Outside that, review every position list by hand; a passing assertion set is not a design review.

## Parts and `part` selector

`tub roof floor_liner rear_liner side_liner roof_liner adapter fit_coupon joint_coupon assembly exploded section`

| part | print orientation | note |
|---|---|---|
| `tub` | floor down, 246 x 240 x 237 | fits 256 bed, 5 mm margin each side |
| `roof` | flat (plate down, posts up) | |
| `floor_liner` `roof_liner` `rear_liner` `side_liner` | flat | print 2x `side_liner` |
| `adapter` | flange down | tape land recess on the bed face |
| `fit_coupon` | ring down | same bore/mouth profile, 14 mm deep: check the hose fit first |
| `joint_coupon` | flat | wall tile with a liner post and an adapter-height post, a liner tile (hole + 6x20 slot) and a 4 mm flange tile, joined by break-away bridges (cut them). Tests the M3x8 + nut stack, the M3x16 adapter stack and the slot. No gasket tape |
| `assembly` `exploded` `section` | view only | not for export |

Optional tool reference (229 x 127 x 127, long axis toward the open front): `-D show_tool=true`, drawn only as a `%` background body in `assembly`/`exploded`/`section`. Never in single-part exports. Not evidence a tool fits.

## Commands

```
make install  # uv sync with the committed lockfile
make export   # individual STL files, treating OpenSCAD warnings as errors
make views    # assembled, exploded and section PNGs
make verify   # formatting, lint, types and geometry/settings tests
```

Use OpenSCAD 2026.10.11 or a compatible Manifold-enabled build, plus `uv` and `make`. Checks cover nominal exported geometry, not every combination of parameter values. Assembly views are not printable exports.

## Hardware (counts from the model, unverified by a build)

- M3x8 pan head: 28 (20 liner, 8 roof). M3x16: 4 (adapter). M3 nuts: 32.
- Gasket tape lands: adapter flange recess ring (r 22 to 26, 0.6 deep), tub rim (3 mm), frame faces. Tape is not modeled.

## Assembly order / removal is the reverse

1. Fit a nut into every post pocket, from the side. Tack with tape if it falls out (roof posts face down).
2. Tub: slide in `rear_liner` through the open front, screw to the rear posts (long driver, >= 240 mm shaft).
3. Slide in `side_liner` x2 and `floor_liner`; screw each to its posts (M3x8, driver >= 110 mm). Attach `roof_liner` to the separate roof while its underside is accessible.
4. Place the roof/roof-liner subassembly on the tub, then install 8x M3x8 from the top.
5. Adapter from the outside: 4x M3x16 (+ tape on the flange land).

To reach the adapter nuts or rear posts, remove the other liners first.

## Checked

- `openscad` renders all 9 exports with no warnings or assertion failures (Manifold backend).
- Each export: one connected component, watertight, z_min = 0, every extent <= 256.
- Pairwise intersection of the 8 assembled components: zero volume (face contact only), re-run after the gusset change.
- Model assertions: bed fit, documented hose dims, post/pocket/bolt-circle clearances, slot edge distances.

## Not checked

- Full layer-by-layer slicer inspection and project reopen checks remain pending; partial slicing estimates are in `docs/slicing-progress.md`.
- Real screw/nut/hose fit, seal leakage, airflow, stiffness of a 2 mm liner, and whether any tool fits remain untested.
- Dedicated pressure-test ports are not implemented. Do not drill an unplanned opening or treat vacuum pressure as measured airflow.
- Screw lengths are from model arithmetic only; use the joint coupon to confirm.
- M3x16 (adapter) is tight: flange 4 + wall 3 + 5.8 to the nut pocket = 12.8 where the nut starts; nut ends at 15.2 (pocket 15.5), post tip at 16.5. M3x16 projects only about 0.5 to 0.8 mm past the nut and the model has zero allowance for gasket tape thickness, so tape on the flange land (recessed 0.6) eats into thread engagement. Check it with the joint coupon (flange tile + adapter post) before relying on it. M3x18 is NOT a fix: it would run into the post cap.
- Long driver reach for the rear liner and adapter nuts is a usability risk.
