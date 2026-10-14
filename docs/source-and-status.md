# Source and implementation status

Unprinted prototype. CAD and slicing are not yet complete. Do not use for metal grinding, hot particles, or mixed metal/combustible dust collection.

## Inspiration and permissions

- Model: Dust Collector for Sanding / Grinding – Vacuum Fit
- Author: fifindr
- URL: https://makerworld.com/en/models/1020742-dust-collector-for-sanding-grinding-vacuum-fit
- License: Standard Digital File License, verified in the logged-in MakerWorld page on 2026-10-13.
- The displayed terms prohibit sharing, hosting or distributing the model or derivative works, including remixes on other digital platforms. Commercial membership advertising is not evidence of redistribution permission.
- Do not copy, trace, import or redistribute the source model's geometry. Build original enclosure geometry and an independently dimensioned hose connector. The general distributed-pickup concept is inspiration only.

## Overlay pivot, 2026-10-14

The user now wants only an original PETG Translucent shroud over the already-printed MakerWorld collector, preserving its suction system. Read-only source inspection established the mounting dimensions in `overlay-fit.md`: 170 x 130 mm collector body, side caps approximately 19.8 mm above the bottom, and rear top approximately 39.8 mm high, with rising corner transitions. The 155 x 155 mm working envelope is not a mounting-pocket size. The original overlay CAD and STL are now implemented in `cad/overlay-shroud.scad` and `exports/overlay-shroud.stl`. It stands around the collector on the table with removable table-edge and hose-stub seals, avoiding a contoured rim seat. It preserves the existing collector and hose. See `overlay-design.md` for geometry, print orientation and unvalidated physical requirements. The saved overlay P2S project has been reopened and re-sliced: 11h03m / 270.63 g at 0.28 mm, single PETG Translucent, no supports or filament changes. The full gate passes 95 tests without warnings. Physical fit, table/stub seals and safe capture remain unvalidated; no printing occurred.

## Superseded compact redesign, 2026-10-14

The user rejected the large enclosure's 65h40m / 1.59 kg slice and authorized a smaller, monolithic original replacement for their printed MakerWorld collector. The new design uses a 155 x 155 mm clear footprint with broad side access, informed by approximately 115 mm contact height, 125 mm contact depth and 200 mm highest working clearance. See `compact-design.md`. Targets are <400 g / <12 hours including supports and purge. The saved/reopened 0.28 mm experimental slice estimates 256.32 g / 11h15m, meeting those numerical targets, but the Translucent/PLA pairing is excluded from Bambu's mutual-support guide and remains unvalidated. The full gate passes 78 tests. Detailed evidence and remaining release gates are in `compact-design.md`. The old source and manufacturing files remain intact for comparison.

## Superseded large OpenSCAD implementation, 2026-10-14

The user superseded the GUI-only CAD workflow with parametric OpenSCAD. `cad/dust-hood.scad` is the primary source; the Fusion checkpoint is retained unchanged, not a manufacturing source.

Nine independently generated STL designs cover the tub, roof, four liner designs (print two side liners), adapter and two coupons. Front chamber closures, removable liners, captive-nut posts with support gussets and a separate original mounting flange are implemented. Named parameters have documented limits; arbitrary resizing is not validated. Dedicated pressure-test ports remain unimplemented.

The local gate passed formatting, lint, type checking and 56 geometry/settings tests after correcting degenerate gusset faces. Checks include watertight connected solids, positive volume, print bounds, assembled solid interference, the socket profile and invalid-input assertions. Assembly, exploded and section PNGs were regenerated with OpenSCAD warnings treated as errors. These checks do not establish physical fit, printability or airflow.

The eight-plate Bambu project has been saved, reopened and re-sliced; see `slicing-progress.md` for estimates and remaining detailed inspection. No physical printing/testing has occurred. GitHub publication is a prototype checkpoint, not a manufacturing release.

## Historical Fusion checkpoint, 2026-10-14

With the user's permission, `flashlight-holder-v1` was switched to read-only to free an editable slot. Its geometry was not deleted.

`Mind Palace Dust Hood - Prototype` is saved in Fusion. Geometry was created through desktop controls, not a CAD script. The current model contains the main tub, separate roof, floor and rear liners, two instances of the side liner, and a roof liner. Entered dimensions include a 246 by 240 by 237 mm tub, 3 mm shell/roof, 2 mm liners and nominal 10 mm chambers. These are modeling inputs, not completed dimensional verification.

The floor and rear have four rounded slots each, the side liners three each, and the roof liner two. Slot inputs were 14 mm center spacing and 6 mm width (20 mm overall length). The side-liner profile area was checked in Fusion at 51,010.56 square mm (230.4 by 221.4 mm); its three through-slots were visually confirmed before duplication. Assembly clearances and every feature still require independent checks.

`cad/mind-palace-dust-hood-incomplete.f3d` is a local checkpoint, not a manufacturing release. Supports, front chamber closures, sealing details, fasteners, collector/outlet, independently measured hose adapter, tool reference, exploded/section views and coupons remain unfinished. Do not print this checkpoint as a functional collector. At the time this Fusion checkpoint was saved, no Bambu slicing, warning clearance, print estimate, fit test or airflow test had been completed and nothing had been published. Subsequent OpenSCAD progress is recorded above.

## Hose interface reference, 2026-10-14

The user explicitly selected the same hose specifications as the already-printed MakerWorld 32 mm variant. Physical hose measurements are no longer a prerequisite for modeling this interface, but the new print still requires a fit test.

The listing only publishes a nominal 32 mm diameter. The selected profile downloaded separately as `~/Downloads/DustCollectorV2_32mm(2).3mf`, containing `DrillDust_32mmDiameter.stl`. It was opened separately in Bambu Studio for inspection, not imported into the enclosure or included in distributable files. Read-only numerical inspection of its mesh established the mating dimensions. The current enclosure independently reconstructs them in OpenSCAD.

- Archive SHA256: `544f7daeecce3cc5e5a308c9d9277c5f795599e89257215dc2b1688d17c2e0bc`.
- Model units: millimeters; component transform is identity and placement has translation only, with no scaling.
- Socket bore: 32.10 mm diameter, straight from source axial coordinates 45 to 84 mm, giving 39 mm straight engagement.
- Mouth: 1 mm-radius internal fillet over axial coordinates 84 to 85 mm, opening to 34.10 mm diameter. This is NOT a conical taper or a 45-degree chamfer.
- Total socket depth from mouth to shoulder plane: 40 mm.
- Cylindrical exterior: 39.80 mm diameter. The source's flattened base and collector geometry are not needed for hose compatibility and will not be copied.
- Bore verification: 22,148 sampled vertices, maximum radial residual 0.000447 mm from radius 16.05 mm.
- Mouth verification: 15,360 sampled vertices, maximum residual 0.001026 mm from a 1 mm-radius round centered at axial 84 mm and radial 17.05 mm.

Reconstruct only this functional interface with original CAD features and an original mounting flange. Do not redistribute the downloaded archive, meshes, source images, or a copied connector. These are source-mesh dimensions, not evidence of fit for a new material, printer profile or hose.

## Publication gates

Public GitHub publication is authorized for independently created, verified prototype files, labeled unprinted. MakerWorld publication must wait for the user's physical print and testing, corrections as needed, and permission checks. Do not start a print remotely.
