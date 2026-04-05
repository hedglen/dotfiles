"""
move.py — classify and move renamed videos from the inbox into the media library.

Usage:
    python move.py              # preview (dry run)
    python move.py --apply      # apply moves
    python move.py --dest x     # force everything to x
    python move.py --dest movies
    python move.py --dest tv
    python move.py --dest music_videos
"""

import sys
import shutil
import argparse
from pathlib import Path

import tomllib
from guessit import guessit
from rich.console import Console
from rich.table import Table
from rich import box

console = Console(highlight=False)

# ── config ────────────────────────────────────────────────────────────────────

CONFIG_PATH = Path(__file__).parent / "config.toml"

with open(CONFIG_PATH, "rb") as f:
    CONFIG = tomllib.load(f)

PATHS      = {k: Path(v) for k, v in CONFIG["paths"].items()}
VIDEO_EXTS = set(CONFIG["extensions"]["video"])
X_PREFIXES = [p.upper() for p in CONFIG["x_patterns"]["prefixes"]]
X_KEYWORDS = [k.lower() for k in CONFIG["x_patterns"]["keywords"]]

DEST_LABELS = {
    "x":            "[dim white]x[/dim white]",
    "movies":       "[cyan]Movies[/cyan]",
    "tv":           "[yellow]TV Shows[/yellow]",
    "music_videos": "[magenta]Music Videos[/magenta]",
    "unknown":      "[red]? unknown[/red]",
}

# ── classifier ────────────────────────────────────────────────────────────────

def classify(path: Path) -> str:
    """Return destination key: 'x' | 'movies' | 'tv' | 'music_videos' | 'unknown'"""
    name_upper = path.stem.upper()

    # x patterns take priority
    if any(name_upper.startswith(p) for p in X_PREFIXES):
        return "x"
    if any(kw in path.stem.lower() for kw in X_KEYWORDS if kw):
        return "x"

    info = guessit(path.name)
    kind = info.get("type")

    if kind == "movie":
        return "movies"
    if kind == "episode":
        return "tv"

    # Fallback heuristics
    stem_lower = path.stem.lower()
    if any(w in stem_lower for w in ("music video", "mv ", " mv", "official video", "official audio")):
        return "music_videos"

    return "x"  # default: x


# ── build destination path ────────────────────────────────────────────────────

def dest_path(path: Path, dest_key: str) -> Path:
    """Build the full destination path for a file."""
    base = PATHS.get(dest_key)
    if not base:
        return PATHS["x"] / path.name

    if dest_key == "movies":
        # Use the stem as-is for the folder — it's already clean from rename.py
        # Strip just the episode/quality suffix if any, keep "Title (Year)" shape
        info   = guessit(path.name)
        title  = str(info.get("title", "")).strip()
        year   = info.get("year")
        folder = f"{title} ({year})" if (title and year) else path.stem
        return base / folder / path.name

    if dest_key == "tv":
        info   = guessit(path.name)
        title  = str(info.get("title", path.stem)).strip()
        season = info.get("season")
        subfolder = f"Season {season:02d}" if season else "Season 01"
        return base / title / subfolder / path.name

    # x, music_videos — flat
    return base / path.name


# ── main ──────────────────────────────────────────────────────────────────────

VALID_DESTS = ("x", "movies", "tv", "music_videos")

def main():
    parser = argparse.ArgumentParser(description="Move renamed videos to the media library.")
    parser.add_argument("--apply", action="store_true", help="Apply moves (default is dry run)")
    parser.add_argument("--dest",  choices=VALID_DESTS,  help="Force all files to this destination")
    parser.add_argument("--dir",   default=str(PATHS["inbox"]), help="Folder to scan")
    args = parser.parse_args()

    folder = Path(args.dir)
    if not folder.exists():
        console.print(f"[red]Folder not found:[/red] {folder}")
        sys.exit(1)

    files = sorted(f for f in folder.iterdir() if f.is_file() and f.suffix.lower() in VIDEO_EXTS)
    if not files:
        console.print("[yellow]No video files found.[/yellow]")
        return

    table = Table(box=box.SIMPLE_HEAVY, show_header=True, header_style="bold cyan")
    table.add_column("File",        no_wrap=False)
    table.add_column("Dest",        width=14)
    table.add_column("Path in library", no_wrap=False, style="dim")

    moves: list[tuple[Path, Path]] = []

    for f in files:
        dest_key = args.dest if args.dest else classify(f)
        dst      = dest_path(f, dest_key)
        label    = DEST_LABELS.get(dest_key, dest_key)
        rel      = dst.relative_to(PATHS[dest_key].parent) if dst.is_relative_to(PATHS[dest_key].parent) else dst
        table.add_row(f.name, label, str(rel))
        moves.append((f, dst))

    console.print(table)

    if not args.apply:
        console.print(f"[yellow]Dry run -- {len(moves)} file(s) would be moved. Pass --apply to commit.[/yellow]")
        return

    errors = 0
    for src, dst in moves:
        if dst.exists():
            console.print(f"[red]SKIP (exists):[/red] {dst.name}")
            errors += 1
            continue
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(src), str(dst))

    console.print(f"[green]Moved {len(moves) - errors} file(s).[/green]")


if __name__ == "__main__":
    main()
