# Overlay shroud: source-derived mounting dimensions

Current direction: an original PETG Translucent shroud fitted over the user's existing printed MakerWorld collector. Do not replace the collector or reproduce its plenum, floor, socket or mesh. The previous compact replacement and large enclosure are superseded references.

The user requested closed remaining surfaces with a connected access opening across the adjacent motor-entry and tool-entry faces. Use the front and right faces, consistent with the photographed setup. The user explicitly directed us not to investigate opposite-wall workpiece clearance further. This does not establish collision-free physical operation.

## Source and method

Read-only numerical inspection of the separately downloaded source 3MF, using mesh sections and coordinate probes. Both `DustCollectorV2_32mm.3mf` and `DustCollectorV2_32mm(2).3mf` have the same SHA256:

`544f7daeecce3cc5e5a308c9d9277c5f795599e89257215dc2b1688d17c2e0bc`

Model units are millimeters. The component transform is identity; build placement is translation only, not scaling. The source mesh has 205,321 vertices, with bounds approximately X -85..85, Y -85..85 and Z -19.900425..19.900425. Nothing from the mesh is imported into or redistributed with this project. These measurements describe the modeled part, not the user's physical print.

## Mating dimensions

| Feature | Source-derived dimension |
| --- | --- |
| Collector body footprint, excluding hose stub | 170 mm wide x 130 mm deep |
| Total footprint, including rear hose stub | 170 x 170 mm |
| Body front / rear planes | Y=-85 / Y=45 |
| Hose mouth plane | Y=85 |
| Side upper seating height above bottom datum | Approximately 19.8 mm |
| Rear upper height above bottom datum | Approximately 39.8 mm |
| Outer rear corner plan radius | Approximately 30 mm |
| Side cap thickness | Approximately 1.2 mm, over a hollow plenum |
| Inner width near cap underside | Approximately 151.2 mm |
| Side cap projected width | Approximately 9.4 mm per side, not all flat gasket land |

The upper edge is NOT a level rectangular rim. Side caps are lower than the rear edge, and the rear corners transition upward. The front cap ends also slope down. The opening flares outward with height, approximately 16.7 degrees from vertical; its floor-level width is only about 140.7 mm.

The exterior wall edges are rounded. In particular, a probe at X=85, Y approximately 0 reaches only source Z=-1.2754, below the cap's approximately Z=-0.1 top plane. Do not treat the entire projected cap width as a flat sealing land or infer a square-edged seat from the outside bounding box. Use a narrow gasket on the interior flat portion, away from both the opening and rounded exterior edge.

## Fit implications

- The approved 155 x 155 mm is upper working clearance, not the collector's outer mounting footprint. A 155 mm-wide skirt cannot slip over a 170 mm-wide collector.
- An original mounting flange can extend outward while preserving 155 mm clear width above it. A nominal outside locating pocket of about 171..171.5 mm provides a starting allowance, not proven printed fit.
- A 155 mm-deep cover also exceeds the body's 130 mm depth. Its extension and perimeter closure must be designed explicitly; a floating overhang must not become an unintended third air opening underneath.
- The seating interface must accommodate the approximately 20 mm height change from side caps to rear top. Do not model a flat 170 x 130 mm collar and claim it seals.
- Avoid a wedging inner lip in the tapered opening. Use low-load external location and removable compressible gasket tape on supported lands; the existing cap is thin and hollow underneath.
- Keep the existing suction slots and rear hose connection unobstructed. No new hose socket is required.

The contact/working measurements remain approximately 115 mm contact height, 125 mm contact depth and 200 mm highest working clearance, referenced to the user's setup. Roof clearance needs margin above 200 mm. The existing collector stays in place, unlike the superseded replacement concept.

The implemented candidate is described in [overlay-design.md](overlay-design.md). It uses a table-supported outer skirt and a gasketed hose-stub arch instead of the rim-seat concept considered above; no contoured rim profile is needed. This is original geometry, not a traced collector surface. The source and print-oriented STL are available, with slicing still pending. Targets remain <400 g / <12 hours including supports. Initial overlay slicing uses PETG Translucent alone, avoiding the earlier experimental PLA interface pairing. No prints are started remotely, and the prior metal-dust/spark safety limitations still apply.
