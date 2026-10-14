"""Check default assembly clearances and the independently reconstructed socket.

References:
- https://trimesh.org/trimesh.boolean.html
- https://openscad.org/documentation.html
- ../docs/source-and-status.md
"""

from __future__ import annotations

import itertools
import shutil
import subprocess
from pathlib import Path

import numpy as np
import pytest
import trimesh

ROOT = Path(__file__).resolve().parents[1]


def load_part(name: str) -> trimesh.Trimesh:
    """Load a default export.

    Parameters:
        name (str): Manufacturing selector name.
    Returns:
        trimesh.Trimesh: Independent mesh instance for placement or measurement.
    """
    mesh = trimesh.load_mesh(ROOT / "exports" / f"{name}.stl")
    assert isinstance(mesh, trimesh.Trimesh)
    return mesh


def test_default_assembly_has_no_solid_interference() -> None:
    """Check all eight placed solids; touching mating faces are permitted."""
    parts = {
        name: load_part(name)
        for name in ("tub", "roof", "floor_liner", "roof_liner", "rear_liner", "adapter")
    }
    parts["floor_liner"].apply_translation([15.2, 1, 13])
    parts["roof_liner"].apply_translation([15.2, 1, 225])
    parts["roof"].apply_transform([[1, 0, 0, 0], [0, -1, 0, 240], [0, 0, -1, 240], [0, 0, 0, 1]])
    parts["rear_liner"].apply_transform(
        [[1, 0, 0, 15.2], [0, 0, -1, 227], [0, 1, 0, 15.2], [0, 0, 0, 1]]
    )
    parts["adapter"].apply_transform(
        [[1, 0, 0, 123], [0, 0, 1, 240], [0, -1, 0, 120], [0, 0, 0, 1]]
    )
    left = load_part("side_liner")
    left.apply_transform([[0, 0, 1, 13], [1, 0, 0, 1], [0, 1, 0, 13], [0, 0, 0, 1]])
    right = left.copy()
    right.apply_transform([[-1, 0, 0, 246], [0, 1, 0, 0], [0, 0, -1, 240], [0, 0, 0, 1]])
    parts["left"] = left
    parts["right"] = right
    for (name_a, mesh_a), (name_b, mesh_b) in itertools.combinations(parts.items(), 2):
        overlap = trimesh.boolean.intersection([mesh_a, mesh_b], engine="manifold")
        # Signed tetrahedron volume also handles zero-volume contact surfaces;
        # Trimesh mass-properties divides by zero computing their centroid.
        triangles = overlap.triangles
        volume = (
            np.einsum("ij,ij->i", triangles[:, 0], np.cross(triangles[:, 1], triangles[:, 2])).sum()
            / 6
        )
        assert abs(volume) < 0.01, f"Interference: '{name_a}' / '{name_b}'"


@pytest.mark.parametrize(("part", "base", "depth"), [("adapter", 4, 40), ("fit_coupon", 3, 14)])
def test_socket_nominal_profile(part: str, base: float, depth: float) -> None:
    """Check bore/mouth vertices and the round rather than a conical lead-in."""
    mesh = load_part(part)
    vertices = mesh.vertices
    radius = np.linalg.norm(vertices[:, :2], axis=1)
    mouth = np.isclose(vertices[:, 2], base + depth, atol=0.002)
    assert mouth.any()
    assert np.min(radius[mouth]) == pytest.approx(17.05, abs=0.002)
    assert np.max(radius[mouth]) == pytest.approx(19.9, abs=0.002)
    bore_start = np.isclose(vertices[:, 2], base, atol=0.02) & (radius > 15)
    assert bore_start.any()
    assert np.min(radius[bore_start]) == pytest.approx(16.05, abs=0.002)
    arc = (
        (vertices[:, 2] > base + depth - 1 + 0.002)
        & (vertices[:, 2] < base + depth - 0.002)
        & (radius < 17.1)
    )
    assert arc.sum() > 100
    residual = np.hypot(radius[arc] - 17.05, vertices[arc, 2] - (base + depth - 1))
    assert np.allclose(residual, 1.0, atol=0.002)


@pytest.mark.parametrize("override", ['part="not-a-part"', "W=300", "chamber=2"])
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
        'part="adapter"',
        "-D",
        override,
        str(ROOT / "cad" / "dust-hood.scad"),
    ]
    with pytest.raises(subprocess.CalledProcessError) as result:
        subprocess.check_output(command, text=True, stderr=subprocess.STDOUT, timeout=30)
    assert "Assertion" in result.value.output
