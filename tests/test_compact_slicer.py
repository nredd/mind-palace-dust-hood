"""Check the experimental compact project, not material compatibility.

References:
- https://github.com/bambulab/BambuStudio
- https://wiki.bambulab.com/en/filament-acc/filament/h2d-pla-and-petg-mutual-support
"""

from __future__ import annotations

import json
import zipfile
from pathlib import Path
from xml.etree import ElementTree

import numpy as np
import trimesh

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "slicer" / "compact-hood-experimental-p2s.3mf"


def test_experimental_material_and_support_settings() -> None:
    """Pin the requested but manufacturer-undocumented Translucent/PLA pairing."""
    with zipfile.ZipFile(PROJECT) as archive:
        cfg = json.loads(archive.read("Metadata/project_settings.config"))
    expected = {
        "printer_settings_id": "Bambu Lab P2S 0.4 nozzle",
        "curr_bed_type": "Textured PEI Plate",
        "layer_height": "0.28",
        "initial_layer_print_height": "0.2",
        "wall_loops": "4",
        "top_shell_layers": "5",
        "bottom_shell_layers": "5",
        "enable_support": "1",
        "support_filament": "1",
        "support_interface_filament": "2",
        "support_top_z_distance": "0",
        "support_bottom_z_distance": "0",
        "support_interface_top_layers": "3",
        "support_interface_spacing": "0",
        "flush_into_infill": "0",
        "flush_into_support": "0",
        "enable_prime_tower": "1",
    }
    for key, value in expected.items():
        assert cfg[key] == value, key
    assert cfg["filament_settings_id"] == [
        "Bambu PETG Translucent @BBL P2S 0.4 nozzle",
        "Bambu PLA Basic @BBL P2S",
    ]


def test_saved_project_contains_current_unrepaired_hood() -> None:
    """Reject stale flat-canopy geometry and accidental extra printable bodies."""
    with zipfile.ZipFile(PROJECT) as archive:
        cfg = ElementTree.fromstring(archive.read("Metadata/model_settings.config"))
        model = ElementTree.fromstring(archive.read("3D/Objects/object_1.model"))
        assembly = ElementTree.fromstring(archive.read("3D/3dmodel.model"))
    assert len(cfg.findall("object")) == 1
    assert len(cfg.findall("plate/model_instance")) == 1
    name = cfg.find("object/metadata[@key='name']")
    extruder = cfg.find("object/metadata[@key='extruder']")
    assert name is not None and name.attrib["value"] == "compact-hood.stl"
    assert extruder is not None and extruder.attrib["value"] == "1"
    stats = cfg.find("object/part/mesh_stat")
    assert stats is not None
    for key, value in stats.attrib.items():
        if key != "face_count":
            assert int(value) == 0, key
    vertices = np.array(
        [
            [float(item.attrib[axis]) for axis in "xyz"]
            for item in model.findall(".//{*}vertices/{*}vertex")
        ]
    )
    item = assembly.find("{*}build/{*}item")
    component = assembly.find(".//{*}component")
    assert item is not None and component is not None
    transform = np.fromstring(item.attrib["transform"], sep=" ")
    assert np.array_equal(transform[:9], np.eye(3).flatten())
    assert component.attrib["transform"] == "1 0 0 0 1 0 0 0 1 0 0 0"
    placed = vertices + transform[9:]
    assert abs(placed[:, 2].min()) < 0.0001
    assert placed[:, :2].min() >= 5
    assert placed[:, :2].max() <= 251
    faces = np.array(
        [
            [int(item.attrib[key]) for key in ("v1", "v2", "v3")]
            for item in model.findall(".//{*}triangles/{*}triangle")
        ]
    )
    saved = trimesh.Trimesh(vertices=vertices, faces=faces)
    exported = trimesh.load_mesh(ROOT / "exports" / "compact-hood.stl")
    assert isinstance(exported, trimesh.Trimesh)
    assert saved.is_volume
    assert len(saved.faces) == len(exported.faces)
    assert saved.vertices.shape == exported.vertices.shape
    # Reload from disk can retain stale source_offset metadata. Compare shape
    # independent of translation; the actual build transform is checked above.
    saved_vertices = saved.vertices - saved.bounds.mean(axis=0)
    exported_vertices = exported.vertices - exported.bounds.mean(axis=0)
    saved_sorted = saved_vertices[np.lexsort(saved_vertices.T)]
    exported_sorted = exported_vertices[np.lexsort(exported_vertices.T)]
    assert np.allclose(saved_sorted, exported_sorted, atol=0.0001, rtol=0)
