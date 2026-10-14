"""Check the monolithic compact hood export, not physical fit or airflow.

Heights are table-referenced: z=0 is the table and the floor underside.

References:
- https://trimesh.org/trimesh.boolean.html
- https://openscad.org/documentation.html
- ../docs/source-and-status.md
"""

from __future__ import annotations

import shutil
import subprocess
from pathlib import Path

import numpy as np
import pytest
import trimesh

ROOT = Path(__file__).resolve().parents[1]
EXPORT = ROOT / "exports" / "compact-hood.stl"
SCAD = ROOT / "cad" / "compact-hood.scad"
BED_MM = 256.0
TOL = 0.01
PETG_G_PER_CM3_UPPER = 1.30
MASS_LIMIT_G = 400.0
CX = 77.5  # centre plane of the 155 mm interior
AXIS = np.array([CX, 30.0])  # socket axis in (x, z)


@pytest.fixture(scope="module")
def hood() -> trimesh.Trimesh:
    """Load the required export, failing if it is missing.

    Returns:
        trimesh.Trimesh: Loaded compact hood mesh (read-only use).
    """
    assert EXPORT.is_file(), f"Missing compact hood export: '{EXPORT}'"
    result = trimesh.load_mesh(EXPORT)
    assert isinstance(result, trimesh.Trimesh), f"Expected one mesh: '{EXPORT}'"
    return result


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


def overlap_volume(
    mesh: trimesh.Trimesh, lo: tuple[float, float, float], hi: tuple[float, float, float]
) -> float:
    """Measure solid volume of `mesh` inside a probe box.

    Parameters:
        mesh (trimesh.Trimesh): Hood mesh.
        lo (tuple[float, float, float]): Probe minimum corner.
        hi (tuple[float, float, float]): Probe maximum corner.
    Returns:
        float: Overlap volume in mm^3 (0.0 when empty).
    """
    overlap = trimesh.boolean.intersection([mesh, box(lo, hi)], engine="manifold")
    triangles = overlap.triangles
    if len(triangles) == 0:
        return 0.0
    cross = np.cross(triangles[:, 1], triangles[:, 2])
    return float(abs(np.einsum("ij,ij->i", triangles[:, 0], cross).sum() / 6))


def test_closed_positive_connected(hood: trimesh.Trimesh) -> None:
    """Require one closed, consistently wound, positive-volume solid."""
    assert len(hood.faces) > 0
    assert np.isfinite(hood.vertices).all()
    assert hood.is_watertight
    assert hood.is_winding_consistent
    assert hood.is_volume
    assert hood.volume > 0
    assert len(hood.split(only_watertight=False)) == 1


def test_floor_and_bounds(hood: trimesh.Trimesh) -> None:
    """Check bed fit, a Z=0 floor, the 227 canopy height and the 155 clear depth."""
    assert abs(hood.bounds[0, 2]) <= TOL
    assert np.all(hood.extents <= BED_MM + TOL)
    assert hood.bounds[1, 2] == pytest.approx(227.0, abs=TOL)
    assert hood.bounds[0, 1] == pytest.approx(0.0, abs=TOL)
    # Floor probe: exactly 2 mm of solid, nothing between z=2 and the canopy.
    floor = overlap_volume(hood, (10, 10, 0), (145, 100, 2))
    assert floor == pytest.approx(135 * 90 * 2, rel=1e-6)
    assert overlap_volume(hood, (10, 10, 2.001), (145, 100, 227)) < TOL


def test_mass_upper_bound(hood: trimesh.Trimesh) -> None:
    """Bound solid PETG mass only; supports, purge and brim are not counted."""
    grams = hood.volume / 1000.0 * PETG_G_PER_CM3_UPPER
    assert grams < MASS_LIMIT_G, f"Solid mass '{grams:.0f}' g"


def test_clear_footprint(hood: trimesh.Trimesh) -> None:
    """Interior 155 x 155 stays empty up to the 200 mm tool height."""
    assert overlap_volume(hood, (0, 0, 2.001), (155, 155, 200)) < TOL
    # Positive control: the probe would see the floor and rear wall just outside.
    assert overlap_volume(hood, (0, 0, 0), (155, 155, 2)) > 0
    assert overlap_volume(hood, (0, 155, 2.001), (155, 157, 200)) > 0


def test_canopy_underside_clears_tools(hood: trimesh.Trimesh) -> None:
    """Nothing hangs below 210 over the interior except the floor and walls."""
    assert overlap_volume(hood, (-2, 0, 200), (157, 155, 209.999)) < TOL
    assert overlap_volume(hood, (-2, 140, 210), (157, 155, 212)) > 0  # canopy exists


def test_canopy_slope_45_degrees(hood: trimesh.Trimesh) -> None:
    """Underside rises 210 -> 225 over y 155 -> 140, 2 mm vertical thickness, rear 212."""
    for y in (141.0, 147.5, 154.0):
        under = 210 + (155 - y)
        # Solid just above the underside, void just below it, void above the top.
        assert overlap_volume(hood, (0, y - 0.5, under + 0.2), (155, y + 0.5, under + 1.8)) > 0
        assert overlap_volume(hood, (0, y - 0.5, under - 1.5), (155, y + 0.5, under - 0.51)) < TOL
        assert overlap_volume(hood, (0, y - 0.5, under + 3.6), (155, y + 0.5, 240)) < TOL
    # Front edge top is 227; rear wall and ribs stay 212 behind y=157.
    assert overlap_volume(hood, (0, 139, 2.001), (155, 140, 240)) < TOL
    assert overlap_volume(hood, (-2, 157, 212.001), (157, 170, 240)) < TOL
    assert overlap_volume(hood, (-2, 157, 211), (157, 170, 212)) > 0


def test_side_tool_access_at_contact_height(hood: trimesh.Trimesh) -> None:
    """Broad side openings at 115 mm run front to rear wall, joined to the front."""
    for x_lo, x_hi in ((-2, 0), (155, 157)):
        assert overlap_volume(hood, (x_lo, 0, 57.001), (x_hi, 155, 209.999)) < TOL
    # Contact height band, behind-front y=125, plus a wide lateral sweep lane.
    assert overlap_volume(hood, (-60, 95, 100), (217, 155, 130)) < TOL
    assert overlap_volume(hood, (-60, -50, 57.001), (217, 155, 209.999)) < TOL
    # Positive control: the low side walls are solid below 57.
    assert overlap_volume(hood, (-2, 0, 0), (0, 155, 57)) > 0


def _radii(hood: trimesh.Trimesh, y: float, atol: float = 0.002) -> np.ndarray:
    """Radii about the socket axis of vertices in the plane `y`.

    Parameters:
        hood (trimesh.Trimesh): Hood mesh.
        y (float): Plane position.
        atol (float): Plane tolerance.
    Returns:
        np.ndarray: Distances in the XZ plane from the socket axis.
    """
    verts = hood.vertices[np.isclose(hood.vertices[:, 1], y, atol=atol)]
    return np.linalg.norm(verts[:, [0, 2]] - AXIS, axis=1)


def test_socket_section_profile(hood: trimesh.Trimesh) -> None:
    """Check bore, 1 mm round, mouth, OD, shoulder, 25 mm throat and 40 mm depth."""
    mouth = _radii(hood, 199.0)
    assert mouth.size > 0
    assert mouth.min() == pytest.approx(17.05, abs=0.002)
    assert mouth[mouth < 25].max() == pytest.approx(19.9, abs=0.002)
    bore_start = _radii(hood, 159.0, atol=0.02)
    bore = bore_start[(bore_start > 14) & (bore_start < 18)]
    assert bore.size > 0
    assert bore.min() == pytest.approx(16.05, abs=0.002)
    # Throat through the rear wall inner face, y=155.
    throat = _radii(hood, 155.0)
    throat = throat[throat < 20]
    assert throat.min() == pytest.approx(12.5, abs=0.002)
    # Internal ROUND (not a chamfer): residual to the 1 mm arc about (17.05, 198).
    verts = hood.vertices
    r = np.linalg.norm(verts[:, [0, 2]] - AXIS, axis=1)
    arc = (verts[:, 1] > 198.002) & (verts[:, 1] < 198.998) & (r < 17.1)
    assert arc.sum() > 100
    assert np.allclose(np.hypot(r[arc] - 17.05, verts[arc, 1] - 198.0), 1.0, atol=0.002)


def test_socket_is_low_rear_and_open(hood: trimesh.Trimesh) -> None:
    """Socket sits low on the rear, below the belt, bore open to the interior.

    Probe boxes are inscribed in the 25 mm throat and the 32.10 mm bore.
    """
    assert overlap_volume(hood, (CX - 8.5, 155, 21.5), (CX + 8.5, 159, 38.5)) < 1.0
    assert overlap_volume(hood, (CX - 11, 159, 19), (CX + 11, 199, 41)) < 1.0
    assert hood.bounds[1, 1] == pytest.approx(199.0, abs=TOL)  # 40 mm past the shoulder


@pytest.mark.parametrize(
    "override",
    [
        'part="not-a-part"',
        "part=1",
        "floor_t=5",
        "wall_t=1",
        "side_top=80",
        "rear_h=240",
        "socket_d=33",
        "clear_w=160",
        "canopy_proj=40",
    ],
)
def test_invalid_design_inputs_fail(tmp_path: Path, override: str) -> None:
    """Exercise OpenSCAD assertion failures instead of exporting invalid solids."""
    binary = shutil.which("openscad")
    assert binary is not None, "OpenSCAD must be installed for design validation"
    command = [
        str(Path(binary).resolve()),
        "--hardwarnings",
        "-o",
        str(tmp_path / "bad.stl"),
        "-D",
        override,
        str(SCAD),
    ]
    with pytest.raises(subprocess.CalledProcessError) as result:
        subprocess.check_output(command, text=True, stderr=subprocess.STDOUT, timeout=60)
    assert "Assertion" in result.value.output


@pytest.mark.parametrize("view", ["section", "reference"])
def test_view_parts_render(tmp_path: Path, view: str) -> None:
    """Viewing-only selectors must render cleanly (not exported or printed)."""
    binary = shutil.which("openscad")
    assert binary is not None, "OpenSCAD must be installed for design validation"
    command = [
        str(Path(binary).resolve()),
        "--hardwarnings",
        "--export-format",
        "binstl",
        "-D",
        f'part="{view}"',
        "-o",
        str(tmp_path / f"{view}.stl"),
        str(SCAD),
    ]
    subprocess.check_output(command, text=True, stderr=subprocess.STDOUT, timeout=60)
