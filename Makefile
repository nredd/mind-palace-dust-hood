.PHONY: help install export views compact-views format lint type test verify clean

OPENSCAD ?= openscad
PARTS := tub roof floor_liner rear_liner side_liner roof_liner adapter fit_coupon joint_coupon
MESHES := $(addprefix exports/,$(addsuffix .stl,$(PARTS))) exports/compact-hood.stl

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "%-20s %s\n", $$1, $$2}'

install: ## Install locked validation dependencies
	uv sync --locked

export: $(MESHES) ## Render each manufacturing part separately

exports/compact-hood.stl: cad/compact-hood.scad
	@mkdir -p exports
	$(OPENSCAD) --hardwarnings --export-format binstl -D 'part="hood"' -o $@ $<

exports/%.stl: cad/dust-hood.scad
	@mkdir -p exports
	$(OPENSCAD) --hardwarnings --export-format binstl -D 'part="$*"' -o $@ $<

views: ## Render assembled, exploded and section illustrations
	@mkdir -p docs/images
	$(OPENSCAD) --hardwarnings --autocenter --viewall --imgsize=1400,1000 -D 'part="assembly"' -o docs/images/assembly.png cad/dust-hood.scad
	$(OPENSCAD) --hardwarnings --autocenter --viewall --imgsize=1400,1000 -D 'part="exploded"' -o docs/images/exploded.png cad/dust-hood.scad
	$(OPENSCAD) --hardwarnings --autocenter --viewall --camera=600,-200,300,123,120,120 --imgsize=1400,1000 -D 'part="section"' -o docs/images/section.png cad/dust-hood.scad

compact-views: ## Render the compact replacement candidate and its section
	@mkdir -p docs/images
	$(OPENSCAD) --hardwarnings --autocenter --viewall --camera=350,-450,300,79,80,100 --imgsize=1400,1000 -D 'part="hood"' -o docs/images/compact-hood.png cad/compact-hood.scad
	$(OPENSCAD) --hardwarnings --autocenter --viewall --camera=350,-450,300,79,80,100 --imgsize=1400,1000 -D 'part="section"' -o docs/images/compact-section.png cad/compact-hood.scad

format: ## Format Python checks
	uv run ruff format .

lint: ## Check formatting and lint without hiding violations
	uv run ruff format --check .
	uv run ruff check . --ignore-noqa

type: ## Type-check Python checks
	uv run ty check

test: export ## Check actual exported meshes
	uv run pytest

verify: lint type test ## Run static and mesh checks, not print or airflow certification

clean: ## Remove reproducible geometry and view exports
	rm -f $(MESHES) docs/images/assembly.png docs/images/exploded.png docs/images/section.png docs/images/compact-hood.png docs/images/compact-section.png
