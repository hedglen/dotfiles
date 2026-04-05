#!/usr/bin/env python3
"""Small CLI for asking Ollama about files and applying file edits."""

from __future__ import annotations

import argparse
import difflib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Read selected files into Ollama and optionally apply edits."
    )
    parser.add_argument(
        "--model",
        default="qwen2.5-coder:7b",
        help="Ollama model to use. Default: %(default)s",
    )
    parser.add_argument(
        "--ollama-bin",
        default=shutil.which("ollama") or "ollama",
        help="Ollama executable to use. Default: %(default)s",
    )
    parser.add_argument(
        "--file",
        action="append",
        default=[],
        help="File to include. Repeat as needed.",
    )
    parser.add_argument(
        "--glob",
        action="append",
        default=[],
        help="Glob pattern to include, relative to the current directory.",
    )
    parser.add_argument(
        "--max-bytes",
        type=int,
        default=200_000,
        help="Refuse files larger than this size in bytes. Default: %(default)s",
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    ask_parser = subparsers.add_parser("ask", help="Ask a question about files.")
    ask_parser.add_argument(
        "prompt",
        nargs="?",
        help="Question for the model. If omitted, stdin is used.",
    )

    edit_parser = subparsers.add_parser("edit", help="Propose or apply file edits.")
    edit_parser.add_argument(
        "instruction",
        nargs="?",
        help="Editing instruction. If omitted, stdin is used.",
    )
    edit_parser.add_argument(
        "--apply",
        action="store_true",
        help="Write approved changes back to disk.",
    )

    return parser.parse_args()


def fail(message: str, code: int = 1) -> None:
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(code)


def read_prompt(value: str | None, label: str) -> str:
    if value:
        return value.strip()
    if not sys.stdin.isatty():
        return sys.stdin.read().strip()
    fail(f"{label} is required")


def resolve_files(file_args: list[str], glob_args: list[str], max_bytes: int) -> list[Path]:
    candidates: list[Path] = []
    cwd = Path.cwd()

    for entry in file_args:
        candidates.append((cwd / entry).resolve())

    for pattern in glob_args:
        matches = sorted(cwd.glob(pattern))
        if not matches:
            fail(f"glob matched nothing: {pattern}")
        for match in matches:
            candidates.append(match.resolve())

    seen: set[Path] = set()
    files: list[Path] = []
    for path in candidates:
        if path in seen:
            continue
        seen.add(path)
        if not path.exists():
            fail(f"file not found: {path}")
        if not path.is_file():
            fail(f"not a file: {path}")
        size = path.stat().st_size
        if size > max_bytes:
            fail(f"file too large ({size} bytes > {max_bytes}): {path}")
        files.append(path)

    if not files:
        fail("provide at least one --file or --glob")
    return files


def read_files(paths: list[Path]) -> dict[str, str]:
    contents: dict[str, str] = {}
    for path in paths:
        try:
            contents[str(path)] = path.read_text(encoding="utf-8")
        except UnicodeDecodeError as exc:
            fail(f"failed to decode as UTF-8: {path} ({exc})")
    return contents


def render_file_context(contents: dict[str, str]) -> str:
    blocks: list[str] = []
    for path, text in contents.items():
        blocks.append(f"FILE: {path}\n```text\n{text}\n```")
    return "\n\n".join(blocks)


def ollama_chat(
    ollama_bin: str,
    model: str,
    prompt: str,
    *,
    json_mode: bool,
) -> str:
    if os.name == "nt" and len(prompt) > 20_000:
        fail(
            "prompt is too large for reliable Windows CLI execution; run this "
            "script from WSL for larger file sets"
        )

    command = [ollama_bin, "run", model]
    if json_mode:
        command.extend(["--format", "json"])
    command.extend(["--hidethinking", prompt])

    try:
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            encoding="utf-8",
            timeout=600,
            check=False,
        )
    except FileNotFoundError:
        fail(f"ollama executable not found: {ollama_bin}")
    except subprocess.TimeoutExpired:
        fail("ollama request timed out")

    if result.returncode != 0:
        stderr = result.stderr.strip() or "no stderr"
        fail(f"ollama run failed: {stderr}")

    content = result.stdout.strip()
    if not content:
        stderr = result.stderr.strip()
        fail(f"ollama returned no output. stderr: {stderr or 'empty'}")
    return content


def print_diff(path: str, before: str, after: str) -> None:
    diff = difflib.unified_diff(
        before.splitlines(),
        after.splitlines(),
        fromfile=f"{path} (before)",
        tofile=f"{path} (after)",
        lineterm="",
    )
    printed = False
    for line in diff:
        printed = True
        print(line)
    if not printed:
        print(f"No changes for {path}")


def handle_ask(args: argparse.Namespace, contents: dict[str, str]) -> None:
    prompt = read_prompt(args.prompt, "question")
    full_prompt = (
        "You answer questions about local files. Use only the provided file "
        "contents. If something is missing, say so plainly. Return only the final "
        "answer, with no hidden reasoning, preamble, or thinking section.\n\n"
        f"Question:\n{prompt}\n\n"
        "Files:\n"
        f"{render_file_context(contents)}\n"
    )
    answer = ollama_chat(args.ollama_bin, args.model, full_prompt, json_mode=False)
    print(answer.strip())


def parse_edit_response(raw: str) -> dict[str, object]:
    candidate = raw.strip()
    if candidate.startswith("```"):
        parts = candidate.split("```")
        if len(parts) >= 3:
            candidate = parts[1]
            if candidate.startswith("json"):
                candidate = candidate[4:]
    try:
        data = json.loads(candidate)
    except json.JSONDecodeError as exc:
        start = candidate.find("{")
        end = candidate.rfind("}")
        if start != -1 and end != -1 and end > start:
            try:
                data = json.loads(candidate[start : end + 1])
            except json.JSONDecodeError:
                fail(f"model did not return valid JSON: {exc}\n\nRaw response:\n{raw}")
        else:
            fail(f"model did not return valid JSON: {exc}\n\nRaw response:\n{raw}")
    if not isinstance(data, dict):
        fail("model response must be a JSON object")
    return data


def handle_edit(args: argparse.Namespace, contents: dict[str, str]) -> None:
    instruction = read_prompt(args.instruction, "instruction")
    allowed = set(contents.keys())
    full_prompt = (
        "You edit local files. Return strict JSON only with this shape:\n"
        '{"changes":[{"path":"EXACT_INPUT_PATH","content":"FULL_FILE_CONTENT","summary":"short summary"}],"notes":"optional"}\n'
        "Rules:\n"
        "- Only use paths from the provided files.\n"
        "- Omit unchanged files.\n"
        "- content must be the complete final file text.\n"
        "- Do not wrap JSON in markdown.\n\n"
        f"Instruction:\n{instruction}\n\n"
        "Files:\n"
        f"{render_file_context(contents)}\n"
    )
    raw = ollama_chat(args.ollama_bin, args.model, full_prompt, json_mode=True)
    data = parse_edit_response(raw)
    changes = data.get("changes", [])
    if not isinstance(changes, list):
        fail("model response field 'changes' must be a list")

    if not changes:
        print("Model proposed no file changes.")
        notes = data.get("notes")
        if notes:
            print(f"\nNotes:\n{notes}")
        return

    validated: list[tuple[Path, str, str]] = []
    for change in changes:
        if not isinstance(change, dict):
            fail("each change must be an object")
        path_str = change.get("path")
        content = change.get("content")
        if not isinstance(path_str, str) or not isinstance(content, str):
            fail("each change needs string 'path' and 'content' fields")
        if path_str not in allowed:
            fail(f"model returned an unexpected path: {path_str}")
        validated.append((Path(path_str), contents[path_str], content))

    for path, before, after in validated:
        print_diff(str(path), before, after)
        print()

    if not args.apply:
        print("Dry run only. Re-run with --apply to write these changes.")
        return

    for path, _, after in validated:
        path.write_text(after, encoding="utf-8")
        print(f"Applied {path}")

    notes = data.get("notes")
    if notes:
        print(f"\nNotes:\n{notes}")


def main() -> None:
    args = parse_args()
    files = resolve_files(args.file, args.glob, args.max_bytes)
    contents = read_files(files)
    if args.command == "ask":
        handle_ask(args, contents)
    elif args.command == "edit":
        handle_edit(args, contents)
    else:
        fail(f"unknown command: {args.command}")


if __name__ == "__main__":
    main()
