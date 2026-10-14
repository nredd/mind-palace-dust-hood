"""Check exported prototype solids, not physical fit or extraction safety.

References:
- https://trimesh.org/trimesh.html
- https://bambulab.com/en/p2s/specs
"""

from __future__ import annotations

from pathlib import Path

import numpy as np
import pytest
import trimesh

ROOT = Path(__file__).resolve().parents[1]
PARTS = (
    "tub",
    "roof",
    "floor_liner",
    "rear_liner",
    "side_liner",
    "roof_liner",
    "adapter",
    "fit_coupon",
    "joint_coupon",
)
BED_MM = 256.0
TOLERANCE_MM = 0.01


@pytest.fixture(params=PARTS)
def mesh(request: pytest.FixtureRequest) -> trimesh.Trimesh:
    """Load one required manufacturing export, failing if it is missing.

    Parameters:
        request (pytest.FixtureRequest): Current part parameter.
    Returns:
        trimesh.Trimesh: Loaded and vertex-merged manufacturing mesh.
    """
    path = ROOT / "exports" / f"{request.param}.stl"
    assert path.is_file(), f"Missing manufacturing export: '{path}'"
    result = trimesh.load_mesh(path)
    assert isinstance(result, trimesh.Trimesh), f"Expected one mesh: '{path}'"
    return result


def test_finite_coordinates(mesh: trimesh.Trimesh) -> None:
    """Reject empty meshes and non-finite coordinates."""
    assert len(mesh.faces) > 0
    assert np.isfinite(mesh.vertices).all()


def test_closed_positive_solid(mesh: trimesh.Trimesh) -> None:
    """Require closed, consistently wound, positive-volume printable solids."""
    assert mesh.is_watertight
    assert mesh.is_winding_consistent
    assert mesh.is_volume
    assert mesh.volume > 0


def test_connected_part(mesh: trimesh.Trimesh) -> None:
    """Reject detached fastener features and disconnected accidental bodies."""
    assert len(mesh.split(only_watertight=False)) == 1


def test_nominal_build_volume(mesh: trimesh.Trimesh) -> None:
    """Check the nominal bed only; slicer exclusions and brims need separate checks."""
    assert np.all(mesh.extents <= BED_MM + TOLERANCE_MM)
    assert np.all(mesh.extents > TOLERANCE_MM)


def test_floor_down_export(mesh: trimesh.Trimesh) -> None:
    """Require each manufacturing part to rest at Z=0 without below-bed geometry."""
    assert abs(mesh.bounds[0, 2]) <= TOLERANCE_MM
