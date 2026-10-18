"""Fail CI when signing secrets, datasets, or generated private files are tracked."""

from __future__ import annotations

import subprocess
from pathlib import PurePosixPath


FORBIDDEN_NAMES = {"key.properties", ".env"}
FORBIDDEN_SUFFIXES = {".jks", ".keystore"}
FORBIDDEN_ROOTS = {"Data"}


def tracked_files() -> list[str] | None:
    result = subprocess.run(
        ["git", "ls-files", "-z"],
        check=False,
        capture_output=True,
    )
    if result.returncode != 0:
        return None
    return [item.decode("utf-8") for item in result.stdout.split(b"\0") if item]


def violations(paths: list[str]) -> list[str]:
    unsafe: list[str] = []
    for raw_path in paths:
        path = PurePosixPath(raw_path)
        if (
            path.name in FORBIDDEN_NAMES
            or path.suffix.lower() in FORBIDDEN_SUFFIXES
            or (path.parts and path.parts[0] in FORBIDDEN_ROOTS)
            or (path.name.startswith(".env.") and path.name != ".env.example")
        ):
            unsafe.append(raw_path)
    return sorted(unsafe)


def main() -> None:
    paths = tracked_files()
    if paths is None:
        print("Repository hygiene checks skipped: no Git work tree")
        return
    unsafe = violations(paths)
    if unsafe:
        joined = "\n - ".join(unsafe)
        raise SystemExit(f"Archivos prohibidos versionados:\n - {joined}")
    print("Repository hygiene checks passed")


if __name__ == "__main__":
    main()
