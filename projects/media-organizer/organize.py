"""
organize.py — rename + move in one shot.

Usage:
    python organize.py              # preview
    python organize.py --apply      # do it
    python organize.py --dest x     # force all to x
"""

import argparse
import sys
from pathlib import Path

import tomllib
from rich.console import Console
from rich.rule import Rule

from rename import build_name, VIDEO_EXTS
from move import classify, dest_path, PATHS, VALID_DESTS, DEST_LABELS

from rich.table import Table
from rich import box

console = Console(highlight=False)

CONFIG_PATH = Path(__file__).parent / "config.toml"
with open(CONFIG_PATH, "rb") as f:
    CONFIG = tomllib.load(f)


def main():
    parser = argparse.ArgumentParser(description="Rename and move videos from the inbox (default: paths.inbox in config.toml).")
    parser.add_argument("--apply", action="store_true", help="Apply changes (default is dry run)")
    parser.add_argument("--dest",  choices=VALID_DESTS,  help="Force all files to this destination")
    parser.add_argument("--dir",   default=str(PATHS["inbox"]), help="Folder to scan")
    args = parser.parse_args()

    folder = Path(args.dir)
    if not folder.exists():
        console.print(f"[red]Folder not found:[/red] {folder}")
        sys.exit(1)

    files = sorted(f for f in folder.iterdir() if f.is_file() and f.suffix.lower() in VIDEO_EXTS)
    if not files:
        console.print("[yellow]No video files found in inbox.[/yellow]")
        return

    # Build plan: (original, renamed, dest_key, final_dst)
    plan: list[tuple[Path, Path, str, Path]] = []

    for f in files:
        new_stem = build_name(f)
        renamed  = f.with_name(new_stem + f.suffix.lower()) if new_stem else f
        dest_key = args.dest if args.dest else classify(renamed)
        final    = dest_path(renamed, dest_key)
        plan.append((f, renamed, dest_key, final))

    # Preview table
    table = Table(box=box.SIMPLE_HEAVY, show_header=True, header_style="bold cyan")
    table.add_column("Original",    no_wrap=False, style="dim")
    table.add_column("Renamed",     no_wrap=False)
    table.add_column("Dest",        width=14)
    table.add_column("Final path",  no_wrap=False, style="dim")

    for orig, renamed, dest_key, final in plan:
        name_col  = f"[green]{renamed.name}[/green]" if renamed != orig else "[dim](unchanged)[/dim]"
        dest_col  = DEST_LABELS.get(dest_key, dest_key)
        rel       = str(final.relative_to(PATHS[dest_key].parent)) if final.is_relative_to(PATHS[dest_key].parent) else str(final)
        table.add_row(orig.name, name_col, dest_col, rel)

    console.print(table)

    if not args.apply:
        console.print(f"[yellow]Dry run -- {len(plan)} file(s) queued. Pass --apply to commit.[/yellow]")
        return

    errors = 0
    for orig, renamed, dest_key, final in plan:
        if final.exists():
            console.print(f"[red]SKIP (exists):[/red] {final.name}")
            errors += 1
            continue
        final.parent.mkdir(parents=True, exist_ok=True)
        orig.rename(final)

    done = len(plan) - errors
    console.print(f"[green]Done -- {done} file(s) organized.[/green]")


if __name__ == "__main__":
    main()
