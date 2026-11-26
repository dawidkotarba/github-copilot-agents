#!/bin/sh
set -eu
usage() { echo 'Usage: ./install.sh [--dry-run] [--overwrite]'; }
dry=0
overwrite=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry=1 ;;
    --overwrite) overwrite=1 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done
src=$(CDPATH= cd -- "$(dirname -- "$0")/.github/agents" && pwd)
dest=${HOME:?HOME must be set}/.copilot/agents
for file in "$src"/*.agent.md; do
  target=$dest/$(basename "$file")
  if [ -e "$target" ] || [ -L "$target" ]; then
    if cmp -s "$file" "$target"; then echo "Unchanged: $target"; continue; fi
    if [ "$overwrite" -ne 1 ]; then echo "Preserved: $target (use --overwrite to replace)"; continue; fi
    if [ -L "$target" ]; then echo "Refusing symlink: $target" >&2; exit 1; fi
  fi
  if [ "$dry" -eq 1 ]; then echo "Would install: $target"; continue; fi
  mkdir -p "$dest"
  cp "$file" "$target"
  echo "Installed: $target"
done
