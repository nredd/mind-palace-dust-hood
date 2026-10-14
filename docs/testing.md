# Prototype validation and first-use procedure

This is an unprinted prototype, not a certified dust-control system. Passing CAD or slicing checks does not establish physical fit, capture efficiency, visibility, mechanical strength or safe dust compatibility.

## Scope and stop conditions

- Initial trials are limited to compatible cold nonmetal dust. Do not use metal sharpening, hot grit, sparks, flammable dust, mixed metal/combustible residues or combustible solvent vapors as a test load.
- Check the vacuum manufacturer's material restrictions, filtration requirements and operating instructions before selecting any test material. A printed hood does not make the DCV581H suitable for hazardous dust.
- Keep the tool's cooling inlets, controls, belt access, cord and workpiece travel unobstructed. The rectangular CAD tool reference is not an actual tool model.
- Stop if panels deform, the hose detaches, suction collapses, the tool overheats, seals lift, dust escapes or deposited material cannot be removed.
- No print or machine operation is started remotely by this project.

## Before printing the enclosure

1. Review the assembly, exploded and section views. Confirm the inlet-to-rear-outlet path and how every chamber is exposed for cleaning.
2. Slice the fit and joint coupons using the same printer, filament, drying procedure, orientation and settings planned for the full parts.
3. Print only the coupons first. Check hose insertion, retention and release without forcing the fit. Check screw clearance, nut insertion and resistance to nut rotation, and PETG cracking or layer separation.
4. Compare the new socket directly with the user's already-printed 32 mm MakerWorld attachment. The reference mating bore is 32.10 mm, with 39 mm straight engagement and a 1 mm-radius mouth round, not an assumed 32.00 mm bore.
5. Adjust fit parameters and repeat coupons if needed. Do not scale the whole enclosure to fix a connector tolerance.

## Slicer checks

Use Bambu P2S, 0.4 mm nozzle, Bambu PETG Translucent and 0.20 mm Standard as the starting point. Initial structural settings are four wall loops and five top/bottom shell layers. These are not transparency-optimized settings or a proven process.

For every plate:

- Confirm exact profile names and the actual plate type. Do not carry over the A1 mini / PLA profile embedded in the separate MakerWorld reference.
- Verify each object is on the plate, within the printable area including brims and exclusion regions, and at the intended orientation and scale.
- Inspect first-layer adhesion, wall continuity, slots, nut pockets, screw holes, overhangs, transitions and final layers. Check internal air passages for accidental support or infill.
- Resolve warnings by correcting geometry, orientation or supported settings, not by suppressing safeguards. If necessary, reduce the main body footprint and regenerate all dependent parts.
- Record print time and filament per plate, including any required supports and brim. Reopen the saved project and check that the profiles, objects and placements survive.
- Do not call the project warning-free until every plate has actually been sliced and inspected.

## Dry assembly

1. Assemble without the powered tool first. Check fastener length and access, captive nuts, removable panels and hose insertion depth.
2. Apply gasket tape on the specified lands; do not tape over inlet slots, chamber transitions or cooling paths. Do not permanently glue liners in place.
3. Check for front-edge bypass paths into the chambers. Intended suction inlets are the distributed slots, not unsealed gaps at the front.
4. With the tool unplugged, check its full working envelope and representative workpiece motions. Do not proceed if ventilation, handling or access is obstructed.
5. Remove and reinstall every liner and the roof. Confirm no trapped supports, blind pockets or inaccessible debris remain.

## Capture and pressure comparison

Use the same DCV581H, hose, filter condition, power source and test method for the existing attachment and the new hood. Record these conditions; changing them invalidates a direct comparison.

- Check leakage and panel deflection with the vacuum running before introducing dust.
- Use only a small amount of an appropriately assessed cold nonmetal test material. Avoid deliberately dispersing respirable dust. Follow appropriate exposure controls; this prototype is not a replacement for them.
- Record visible escape at the same source position and distance. Photograph deposition in each chamber after a fixed test duration, and record the cleaning time.
- Compare clean and partially loaded states without intentionally clogging the vacuum or defeating its protections.
- If pressure ports are provided, seal unused ports and record gauge pressure with the same setup. Static pressure is **not CFM** and cannot establish capture efficiency by itself.
- Actual airflow measurement requires a suitable flow instrument and method. More slots, more static vacuum or louder airflow is not proof of improved collection.

## Publication gate

GitHub artifacts must be labeled unprinted until physical tests exist. MakerWorld publication requires successful user printing, hose/tool fit checks, structural and cleaning checks, leakage/capture tests, any resulting corrections, and a fresh license review. Keep source-reference downloads out of public artifacts.

Record dates, printer/filament/profile versions, coupon results, photos, failures and revisions. A failed test remains a failure until the revised part is retested.
