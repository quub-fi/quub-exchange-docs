#!/usr/bin/env python3
"""
Lightweight validator: ensure guide-listed HTTP paths exist in the OpenAPI YAML.

Usage:
  python3 scripts/validate_guides.py --guide <guide_path> --openapi <openapi_yaml_path>

Checks performed:
- Extracts paths from guide lines like "GET /orgs/{orgId}/banking/accounts" or full URLs containing "/v2/...".
- Confirms each extracted path substring appears in the OpenAPI YAML file text.

This is a lightweight, conservative check intended to catch obvious deviations from the YAML.
It does not parse the YAML into a complete AST, so it's safe to run without extra dependencies.
"""
import re
import sys
import argparse
from pathlib import Path


def extract_paths_from_guide(text):
    paths = set()
    # Match lines like: GET /orgs/{orgId}/banking/accounts
    for m in re.finditer(r"(?m)^[A-Z]{3,7}\s+(/[^\s'\"]+)", text):
        paths.add(m.group(1).strip())

    # Match full URLs including /v2 path and capture the path portion
    for m in re.finditer(r"https?://[^/]+/v2(/[^\s'\"]+)", text):
        paths.add(m.group(1).strip())

    return sorted(paths)


def main():
    p = argparse.ArgumentParser(description="Validate guide paths against OpenAPI YAML (lightweight)")
    p.add_argument("--guide", required=True, help="Path to guide markdown file")
    p.add_argument("--openapi", required=True, help="Path to OpenAPI YAML file")
    args = p.parse_args()

    guide_path = Path(args.guide)
    openapi_path = Path(args.openapi)
    if not guide_path.exists():
        print(f"ERROR: guide not found: {guide_path}")
        sys.exit(2)
    if not openapi_path.exists():
        print(f"ERROR: openapi not found: {openapi_path}")
        sys.exit(2)

    guide_text = guide_path.read_text(encoding="utf-8")
    openapi_text = openapi_path.read_text(encoding="utf-8")

    paths = extract_paths_from_guide(guide_text)
    if not paths:
        print("No HTTP paths detected in guide (no checks performed).")
        sys.exit(0)

    missing = []
    for pth in paths:
        # Normalize path fragment for search: allow template forms like {orgId}
        if pth not in openapi_text:
            # Try a relaxed check: remove parameter names and match base path segments
            relaxed = re.sub(r"\{[^}]+\}", "{param}", pth)
            if relaxed not in openapi_text:
                missing.append(pth)

    if missing:
        print("Validation FAILED: the following paths were NOT found in the OpenAPI YAML:")
        for m in missing:
            print("  -", m)
        print("\nHint: ensure the guide uses only paths defined in the OpenAPI spec (openapi/*.yaml).")
        sys.exit(3)

    print("Validation OK: all detected guide paths exist in the OpenAPI YAML (lightweight check).")
    sys.exit(0)


if __name__ == '__main__':
    main()
