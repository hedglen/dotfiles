"""
rename.py — batch rename video files in the Downloads inbox.

Usage:
    python rename.py             # preview (dry run)
    python rename.py --apply     # apply renames
    python rename.py --dir "D:/some/other/folder"
"""

import re
import sys
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

VIDEO_EXTS = set(CONFIG["extensions"]["video"])

# ── noise patterns stripped from raw filenames before guessit sees them ───────

_NOISE = re.compile(
    r"""
    \b(
        \d{3,4}p                    # 720p 1080p 2160p
      | 4K | 8K | UHD | HDR | SDR
      | DV | Dolby\.?Vision
      | BluRay | BDRip | BRRip
      | WEBRip | WEB-DL | WEBDL | AMZN | NF | HULU
      | x264 | x265 | HEVC | AVC | H\.?264 | H\.?265
      | AAC | AC3 | DTS | FLAC | MP3 | Atmos | TrueHD
      | EXTENDED | UNRATED | REPACK | PROPER | REMASTERED | REMUX
      | YIFY | YTS | RARBG | EVO | FGT | Tigole | QxR
    )\b
    """,
    re.IGNORECASE | re.VERBOSE,
)

_BRACKETS = re.compile(r"[\(\[\{][^\)\]\}]*[\)\]\}]")  # remove (1080) [720p] etc.
_DOTS     = re.compile(r"(?<=[a-zA-Z0-9])\.(?=[a-zA-Z0-9])")  # word.word → word word
_MULTI_SP = re.compile(r"\s{2,}")


def clean_raw(name: str) -> str:
    """Pre-clean a raw filename string before passing to guessit."""
    name = _BRACKETS.sub(" ", name)
    name = _NOISE.sub(" ", name)
    name = _DOTS.sub(" ", name)
    name = _MULTI_SP.sub(" ", name)
    return name.strip()


# ── build final filename ───────────────────────────────────────────────────────

def build_name(path: Path) -> str | None:
    """Return a clean filename (no extension) for the given video file, or None if unchanged."""
    stem = path.stem
    ext  = path.suffix.lower()

    # Let guessit parse the full filename including extension for best results
    info = guessit(path.name)

    raw_title = str(info.get("title", "")).strip()
    if not raw_title:
        return None

    # Re-attach edition if guessit pulled it out (e.g. "Deluxe", "Extended")
    edition = info.get("edition")
    if edition:
        raw_title = f"{raw_title} {edition}"

    # Clean any residual noise from the title guessit returned
    clean_title = _NOISE.sub(" ", raw_title)
    clean_title = _MULTI_SP.sub(" ", clean_title).strip()
    if not clean_title:
        clean_title = raw_title

    # Title-case, but preserve words that were fully uppercase (acronyms: PMV, BBC, etc.)
    title = " ".join(
        w.upper() if w.isupper() and len(w) > 1 else w.capitalize()
        for w in clean_title.split()
    )

    kind = info.get("type")  # "movie" | "episode"

    if kind == "episode":
        season  = info.get("season")
        episode = info.get("episode")
        ep_title = info.get("episode_title", "")
        if season and episode:
            ep_str = f"S{season:02d}E{episode:02d}"
            ep_str = f"{ep_str} - {ep_title.title()}" if ep_title else ep_str
            new_stem = f"{title} - {ep_str}"
        else:
            new_stem = title
    elif kind == "movie":
        year = info.get("year")
        new_stem = f"{title} ({year})" if year else title
    else:
        # Unknown — just use cleaned title
        new_stem = title

    new_stem = new_stem.strip()
    return new_stem if new_stem != stem else None


# ── main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Batch rename video files in the inbox.")
    parser.add_argument("--apply", action="store_true", help="Apply renames (default is dry run)")
    parser.add_argument("--dir",   default=CONFIG["paths"]["inbox"], help="Folder to scan")
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
    table.add_column("Original",   style="dim",   no_wrap=False)
    table.add_column("->",          style="bold",  width=2)
    table.add_column("Renamed to", style="green", no_wrap=False)

    renames: list[tuple[Path, Path]] = []

    for f in files:
        new_stem = build_name(f)
        if new_stem:
            new_path = f.with_name(new_stem + f.suffix.lower())
            table.add_row(f.name, "->", new_path.name)
            renames.append((f, new_path))
        else:
            table.add_row(f.name, ".", "[dim]unchanged[/dim]")

    console.print(table)

    if not renames:
        console.print("[dim]Nothing to rename.[/dim]")
        return

    if not args.apply:
        console.print(f"[yellow]Dry run — {len(renames)} file(s) would be renamed. Pass --apply to commit.[/yellow]")
        return

    errors = 0
    for src, dst in renames:
        if dst.exists():
            console.print(f"[red]SKIP (exists):[/red] {dst.name}")
            errors += 1
            continue
        src.rename(dst)

    console.print(f"[green]Renamed {len(renames) - errors} file(s).[/green]")


if __name__ == "__main__":
    main()
