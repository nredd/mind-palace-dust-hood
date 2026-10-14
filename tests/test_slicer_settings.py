"""Verify saved project settings, independently of GUI slicing evidence.

References:
- https://github.com/bambulab/BambuStudio
"""

from __future__ import annotations

import json
import zipfile
from collections import Counter
from pathlib import Path
from xml.etree import ElementTree

import pytest

ROOT = Path(__file__).resolve().parents[1]


@pytest.mark.parametrize(
    "filename",
    [
        "p2s-petg-translucent-settings.3mf",
        "coupons-p2s-petg-translucent.3mf",
        "roof-p2s-petg-translucent.3mf",
        "dust-hood-p2s-petg-translucent.3mf",
    ],
)
def test_p2s_petg_settings(filename: str) -> None:
    """Require the agreed machine, material and initial structural settings."""
    with zipfile.ZipFile(ROOT / "slicer" / filename) as archive:
        cfg = json.loads(archive.read("Metadata/project_settings.config"))
    assert cfg["printer_settings_id"] == "Bambu Lab P2S 0.4 nozzle"
    assert cfg["filament_settings_id"] == ["Bambu PETG Translucent @BBL P2S 0.4 nozzle"]
    assert cfg["print_settings_id"] == "0.20mm Standard @BBL P2S"
    assert cfg["curr_bed_type"] == "Textured PEI Plate"
    assert float(cfg["layer_height"]) == 0.2
    assert int(cfg["wall_loops"]) == 4
    assert int(cfg["top_shell_layers"]) == 5
    assert int(cfg["bottom_shell_layers"]) == 5


def test_full_project_inventory_and_unrepaired_meshes() -> None:
    """Require ten instances on eight plates without silent slicer mesh repair."""
    with zipfile.ZipFile(ROOT / "slicer" / "dust-hood-p2s-petg-translucent.3mf") as archive:
        config = ElementTree.fromstring(archive.read("Metadata/model_settings.config"))
    names = Counter(item.attrib["value"] for item in config.findall("object/metadata[@key='name']"))
    expected = Counter(
        f"{name}.stl"
        for name in (
            "tub",
            "roof",
            "floor_liner",
            "rear_liner",
            "roof_liner",
            "side_liner",
            "side_liner",
            "adapter",
            "fit_coupon",
            "joint_coupon",
        )
    )
    assert names == expected
    assert len(config.findall("plate")) == 8
    assigned = [
        item.attrib["value"]
        for item in config.findall("plate/model_instance/metadata[@key='object_id']")
    ]
    assert Counter(assigned) == Counter(item.attrib["id"] for item in config.findall("object"))
    for mesh in config.findall("object/part/mesh_stat"):
        for key, value in mesh.attrib.items():
            if key != "face_count":
                assert int(value) == 0, (key, value)
