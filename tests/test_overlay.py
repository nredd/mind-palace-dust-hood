"""Check the overlay shroud export, not physical fit, seal leakage or airflow.

The export is rear-face-down. Probes run in the ASSEMBLY frame (z=0 is the
table, collector frame in X/Y), recovered with `to_assembly`. The collector is
represented only by an analytic box plus cylinder from `docs/overlay-fit.md`,
never by source geometry.

References:
- https://trimesh.org/trimesh.boolean.html
- https://openscad.org/documentation.html
- ../docs/overlay-fit.md
"""

from __future__ import annotations

import shutil
import subprocess
from pathlib import Path

import numpy as np
import pytest
import trimesh

ROOT = Path(__file__).resolve().parents[1]
EXPORT = ROOT / "exports" / "overlay-shroud.stl"
SCAD = ROOT / "cad" / "overlay-shroud.scad"
BED_MM = 256.0
PETG_G_PER_CM3_UPPER = 1.30
MASS_LIMIT_G = 400.0
REAR_OUT_Y = 50.6  # rear outer face, the bed face when printed
REAR_IN_Y = 48.6
FRONT_Y = REAR_IN_Y - 155.0
ROOF_UNDER_Z = 210.0
POCKET_HALF_W = 85.625
CLEAR_HALF_W = 77.5
STUB_R = 19.9
OPENSCAD = shutil.which("openscad")


def to_assembly(mesh: trimesh.Trimesh) -> trimesh.Trimesh:
    """Rotate the print-oriented mesh back to the installed frame.

    Parameters:
        mesh (trimesh.Trimesh): Print-oriented shroud.
    Returns:
        trimesh.Trimesh: Copy with x=x', y=REAR_OUT_Y - z', z=y'.
    """
    matrix = np.array(
        [[1, 0, 0, 0], [0, 0, -1, REAR_OUT_Y], [0, 1, 0, 0], [0, 0, 0, 1]], dtype=float
    )
    return mesh.copy().apply_transform(matrix)


@pytest.fixture(scope="module")
def printed() -> trimesh.Trimesh:
    """Load the required export, failing if it is missing.

    Returns:
        trimesh.Trimesh: Print-oriented shroud mesh (read-only use).
    """
    assert EXPORT.is_file(), f"Missing overlay export: '{EXPORT}'"
    result = trimesh.load_mesh(EXPORT)
    assert isinstance(result, trimesh.Trimesh), f"Expected one mesh: '{EXPORT}'"
    return result


@pytest.fixture(scope="module")
def shroud(printed: trimesh.Trimesh) -> trimesh.Trimesh:
    """Provide the shroud in the installed (table) frame.

    Parameters:
        printed (trimesh.Trimesh): Print-oriented shroud.
    Returns:
        trimesh.Trimesh: Installed-frame mesh.
    """
    return to_assembly(printed)


def box(lo: tuple[float, float, float], hi: tuple[float, float, float]) -> trimesh.Trimesh:
    """Build an axis-aligned probe box.

    Parameters:
        lo (tuple[float, float, float]): Minimum corner.
        hi (tuple[float, float, float]): Maximum corner.
    Returns:
        trimesh.Trimesh: Box mesh spanning the corners.
    """
    return trimesh.creation.box(
        extents=np.subtract(hi, lo),
        transform=trimesh.transformations.translation_matrix(np.add(hi, lo) / 2),
    )


def collector_envelope() -> trimesh.Trimesh:
    """Build the analytic collector envelope: body box plus D-profile hose stub.

    The stub is a full-width flat-sided lower half (box, z 0..19.9) under a round
    upper half (cylinder). A bounding probe only, not source geometry.

    Returns:
        trimesh.Trimesh: Union of a 170 x 130 x 39.8 box, the stub's lower box
        and the stub's upper cylinder.
    """
    body = box((-85, -85, 0), (85, 45, 39.8))
    stub = trimesh.creation.cylinder(
        radius=STUB_R,
        height=40.0,
        transform=trimesh.transformations.translation_matrix([0, 65.0, STUB_R])
        @ trimesh.transformations.rotation_matrix(np.pi / 2, [1, 0, 0]),
    )
    stub_lower = box((-STUB_R, 45, 0), (STUB_R, 85, STUB_R))
    return trimesh.boolean.union([body, stub, stub_lower], engine="manifold")


def volume_in(mesh: trimesh.Trimesh, probe: trimesh.Trimesh) -> float:
    """Measure solid volume of `mesh` inside a probe mesh.

    Parameters:
        mesh (trimesh.Trimesh): Shroud mesh.
        probe (trimesh.Trimesh): Probe volume.
    Returns:
        float: Overlap volume in mm^3 (0.0 when empty).
    """
    overlap = trimesh.boolean.intersection([mesh, probe], engine="manifold")
    triangles = overlap.triangles
    if len(triangles) == 0:
        return 0.0
    # Signed tetrahedron sum, not `overlap.volume`: that also computes a centre of
    # mass and divides by zero on degenerate (face-contact only) intersections.
    cross = np.cross(triangles[:, 1], triangles[:, 2])
    return float(abs(np.einsum("ij,ij->i", triangles[:, 0], cross).sum() / 6))


def test_closed_positive_connected(printed: trimesh.Trimesh) -> None:
    """The print is one watertight, positive solid."""
    assert printed.is_watertight
    assert printed.is_volume
    assert printed.volume > 0
    assert len(printed.split(only_watertight=False)) == 1


def test_print_orientation_and_bed(printed: trimesh.Trimesh) -> None:
    """Rear face on the bed, every extent inside the 256 mm bed."""
    lo, hi = printed.bounds
    assert lo[2] == pytest.approx(0.0, abs=1e-4)
    assert (hi - lo).max() <= BED_MM
    # Bed face is the rear outer plane: the lowest layer is a full wall plate.
    assert volume_in(printed, box((-90, -1, -1), (90, 230, 0.5))) > 0.9 * 175 * 140 * 0.5


def test_mass_budget(printed: trimesh.Trimesh) -> None:
    """Solid upper-bound mass stays under 400 g (slicer walls are not infill-reduced)."""
    assert printed.volume / 1000 * PETG_G_PER_CM3_UPPER < MASS_LIMIT_G


def test_no_overhang_faces_when_printed(printed: trimesh.Trimesh) -> None:
    """No downward-facing face needs support (every wall is a plain extrusion)."""
    down = printed.face_normals[:, 2] < -1e-3
    assert not down.any() or np.isclose(printed.triangles_center[down][:, 2], 0.0).all()


def test_collector_envelope_fits_without_interference(shroud: trimesh.Trimesh) -> None:
    """The analytic collector envelope does not intersect the shroud."""
    assert volume_in(shroud, collector_envelope()) == pytest.approx(0.0, abs=1.0)


def test_pocket_clearance_over_body(shroud: trimesh.Trimesh) -> None:
    """Side walls sit 0.625 mm off the 170 mm body, below the shoulder."""
    inner_left = box((-90, -100, 0), (-POCKET_HALF_W - 0.01, 40, 40))
    assert volume_in(shroud, inner_left) > 0
    assert POCKET_HALF_W - 85 == pytest.approx(0.625)
    gap = box((-POCKET_HALF_W + 0.01, -100, 0.1), (-85, 40, 40))
    assert volume_in(shroud, gap) == pytest.approx(0.0, abs=1e-6)


def test_clear_footprint_155_and_roof_height(shroud: trimesh.Trimesh) -> None:
    """The 155 x 155 clear footprint is empty from the shoulder to the roof underside."""
    probe = box((-CLEAR_HALF_W, FRONT_Y, 51.0), (CLEAR_HALF_W, REAR_IN_Y, ROOF_UNDER_Z - 1e-3))
    assert volume_in(shroud, probe) == pytest.approx(0.0, abs=1e-6)
    roof = box((-CLEAR_HALF_W, FRONT_Y, ROOF_UNDER_Z), (CLEAR_HALF_W, REAR_IN_Y, 213.0))
    assert volume_in(shroud, roof) > 0.99 * (2 * CLEAR_HALF_W * 155 * 3)


def test_shoulder_stays_above_collector(shroud: trimesh.Trimesh) -> None:
    """Nothing intrudes between the body and the shoulder, so no inlet slot is covered."""
    probe = box((-85.0, -100, 0.0), (85.0, 45, 41.5))
    assert volume_in(shroud, probe) == pytest.approx(0.0, abs=1e-6)


def test_front_opening_full_height(shroud: trimesh.Trimesh) -> None:
    """The front plane is open from the table to the roof underside."""
    probe = box((-CLEAR_HALF_W, FRONT_Y, 0), (CLEAR_HALF_W, FRONT_Y + 1, ROOF_UNDER_Z))
    assert volume_in(shroud, probe) == pytest.approx(0.0, abs=1e-6)


def test_right_opening_connected_to_front(shroud: trimesh.Trimesh) -> None:
    """The right face is open above z=75 for the full depth, no post at the front."""
    probe = box((CLEAR_HALF_W, FRONT_Y, 75.01), (95, REAR_IN_Y, ROOF_UNDER_Z))
    assert volume_in(shroud, probe) == pytest.approx(0.0, abs=1e-6)
    low = box((POCKET_HALF_W, FRONT_Y, 0), (POCKET_HALF_W + 2, REAR_IN_Y, 75))
    assert volume_in(shroud, low) > 0.99 * (2 * 155 * 75)


def test_closed_left_and_rear(shroud: trimesh.Trimesh) -> None:
    """Left wall and rear wall are solid outside the hose arch."""
    left = box((-POCKET_HALF_W - 2, FRONT_Y, 0), (-POCKET_HALF_W, REAR_IN_Y, 41.9))
    assert volume_in(shroud, left) > 0.999 * (2 * 155 * 41.9)
    rear_l = box((-79, REAR_IN_Y, 0), (-21, REAR_OUT_Y, 210))
    rear_r = box((21, REAR_IN_Y, 0), (79, REAR_OUT_Y, 210))
    assert volume_in(shroud, rear_l) > 0.999 * (58 * 2 * 210)
    assert volume_in(shroud, rear_r) > 0.999 * (58 * 2 * 210)
    above = box((-20, REAR_IN_Y, 41.0), (20, REAR_OUT_Y, 210))
    assert volume_in(shroud, above) > 0.999 * (40 * 2 * 169)


def test_hose_arch_clears_stub_with_small_gap(shroud: trimesh.Trimesh) -> None:
    """The 39.8 mm stub passes the rear wall with a 0.6 mm gap, open to the table."""
    stub = trimesh.creation.cylinder(
        radius=STUB_R,
        height=10.0,
        transform=trimesh.transformations.translation_matrix([0, 49.6, STUB_R])
        @ trimesh.transformations.rotation_matrix(np.pi / 2, [1, 0, 0]),
    )
    assert volume_in(shroud, stub) == pytest.approx(0.0, abs=1e-6)
    flat_base = box((-STUB_R, REAR_IN_Y, 0), (STUB_R, REAR_OUT_Y, STUB_R))
    assert volume_in(shroud, flat_base) == pytest.approx(0.0, abs=1e-6)
    ring = box((-20.5, REAR_IN_Y, 0), (-20.4, REAR_OUT_Y, STUB_R))
    assert volume_in(shroud, ring) == pytest.approx(0.0, abs=1e-6)
    beyond = box((-21.0, REAR_IN_Y, 0), (-20.55, REAR_OUT_Y, STUB_R))
    assert volume_in(shroud, beyond) > 0


def test_base_edges_flat_on_table(shroud: trimesh.Trimesh) -> None:
    """Gasket lands: left, right-low and rear edges are flat at z=0."""
    assert shroud.bounds[0][2] == pytest.approx(0.0, abs=1e-4)
    for lo, hi in (
        ((-90, FRONT_Y, 0), (-85, REAR_OUT_Y, 0.2)),
        ((85, FRONT_Y, 0), (90, REAR_OUT_Y, 0.2)),
        ((-90, REAR_IN_Y, 0), (-21, REAR_OUT_Y, 0.2)),
    ):
        assert volume_in(shroud, box(lo, hi)) > 0.99 * (np.subtract(hi, lo).prod() * 0.4)


@pytest.mark.skipif(OPENSCAD is None, reason="openscad is not installed")
def test_scad_renders_and_matches_export(tmp_path: Path, printed: trimesh.Trimesh) -> None:
    """A fresh hard-warnings render reproduces the committed export volume."""
    assert OPENSCAD is not None
    out = tmp_path / "overlay.stl"
    subprocess.check_output(
        [OPENSCAD, "--hardwarnings", "--export-format", "binstl", "-D", 'part="print"']
        + ["-o", str(out), str(SCAD)],
        text=True,
        stderr=subprocess.STDOUT,
    )
    fresh = trimesh.load_mesh(out)
    assert fresh.volume == pytest.approx(printed.volume, rel=1e-4)


@pytest.mark.skipif(OPENSCAD is None, reason="openscad is not installed")
def test_scad_rejects_thin_wall(tmp_path: Path) -> None:
    """The documented wall limit is enforced by an assertion."""
    assert OPENSCAD is not None
    result = subprocess.run(
        [OPENSCAD, "--hardwarnings", "-D", "t=0.8", "-D", 'part="print"']
        + ["-o", str(tmp_path / "bad.stl"), str(SCAD)],
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode != 0
    assert "wall_t" in result.stdout + result.stderr
