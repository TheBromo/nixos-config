#!/usr/bin/env python3
"""
Enforce Lattice MCP for large file exploration, but allow targeted partial reads.

- Hard blocks full reads of files >1000 lines
- Warns for files 500-1000 lines
- Always allows partial reads (with offset/limit)
"""
import json
import sys
import os

HARD_BLOCK_THRESHOLD = 1000  # Block full reads above this
WARN_THRESHOLD = 500         # Warn between 500-1000


def is_text_file(path: str, sample_size: int = 8192) -> bool:
    """
    Check if file is text by looking for null bytes.
    Binary files almost always contain null bytes; text files don't.
    """
    try:
        with open(path, 'rb') as f:
            chunk = f.read(sample_size)
            return b'\x00' not in chunk
    except (IOError, OSError):
        return False


def count_lines(path: str) -> int:
    """Count lines in a file efficiently."""
    try:
        with open(path, 'rb') as f:
            return sum(1 for _ in f)
    except (IOError, OSError):
        return 0


def build_hard_block_guidance(file_path: str, lines: int) -> str:
    return (
        f"BLOCKED: {file_path} has {lines} lines. "
        f"Use Lattice MCP (see CLAUDE.md) or Read with offset/limit."
    )


def build_warn_guidance(file_path: str, lines: int) -> str:
    return (
        f"{file_path} has {lines} lines. "
        f"Consider Lattice MCP (see CLAUDE.md) or Read with offset/limit."
    )


def main():
    data = json.load(sys.stdin)
    tool_input = data.get('tool_input', {})
    file_path = tool_input.get('file_path', '')

    # Check if this is a partial read (already efficient)
    has_limit = 'limit' in tool_input or 'offset' in tool_input

    # Skip if file doesn't exist (let Read handle the error)
    if not os.path.isfile(file_path):
        sys.exit(0)

    # Skip binary files
    if not is_text_file(file_path):
        sys.exit(0)

    lines = count_lines(file_path)

    # Always allow partial reads - they're already efficient
    if has_limit:
        sys.exit(0)

    # Hard block full reads of very large files
    if lines > HARD_BLOCK_THRESHOLD:
        output = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "additionalContext": build_hard_block_guidance(file_path, lines)
            }
        }
        print(json.dumps(output))
        sys.exit(2)

    # Warn for medium-sized files but allow the read
    if lines > WARN_THRESHOLD:
        output = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "additionalContext": build_warn_guidance(file_path, lines)
            }
        }
        print(json.dumps(output))

    sys.exit(0)


if __name__ == '__main__':
    main()
