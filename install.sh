#!/bin/sh
set -eu

usage() {
  printf '%s\n' 'Usage: ./install.sh [--dry-run] [--overwrite]'
}

dry_run=0
overwrite=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=1 ;;
    --overwrite) overwrite=1 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done

src=$(CDPATH= cd -- "$(dirname -- "$0")/.github/agents" && pwd)
dest=${COPILOT_HOME:-${HOME:?HOME must be set}/.copilot}/agents
case "$dest" in
  /*) ;;
  *) dest=./$dest ;;
esac

set -- "$src"/*.agent.md
if [ ! -f "$1" ]; then
  printf 'No agent definitions found in %s\n' "$src" >&2
  exit 1
fi

if [ -e "$dest" ] && [ ! -d "$dest" ]; then
  printf 'Agent destination is not a directory: %s\n' "$dest" >&2
  exit 1
fi

scratch=
trap 'if [ -n "$scratch" ]; then rm -f "$scratch"/*.agent.md; rmdir "$scratch"; fi' 0
trap 'exit 1' HUP INT TERM

for file in "$@"; do
  name=${file##*/}
  target=$dest/$name
  legacy=$dest/${name%.agent.md}.md
  replace=0

  if [ -e "$legacy" ] || [ -L "$legacy" ]; then
    printf 'Preserved: %s (same agent ID; move it aside to install %s)\n' "$legacy" "$name"
    continue
  fi
  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ -f "$target" ] && [ ! -L "$target" ] && cmp -s "$file" "$target"; then
      printf 'Unchanged: %s\n' "$target"
      continue
    fi
    if [ "$overwrite" -eq 0 ]; then
      printf 'Preserved: %s (use --overwrite to replace regular files)\n' "$target"
      continue
    fi
    if [ -L "$target" ] || [ ! -f "$target" ]; then
      printf 'Refusing to replace a symlink or non-regular file: %s\n' "$target" >&2
      exit 1
    fi
    replace=1
  fi

  if [ "$dry_run" -eq 1 ]; then
    if [ "$replace" -eq 1 ]; then
      printf 'Would replace: %s\n' "$target"
    else
      printf 'Would install: %s\n' "$target"
    fi
    continue
  fi

  if [ -z "$scratch" ]; then
    mkdir -p "$dest"
    scratch=$(mktemp -d "$dest/.install-agents.XXXXXXXX")
  fi
  cp "$file" "$scratch/$name"
  if [ "$replace" -eq 1 ]; then
    mv -f "$scratch/$name" "$dest/"
  else
    # Publish the complete file without replacing an existing file.
    ln "$scratch/$name" "$dest/"
    rm -f "$scratch/$name"
  fi
  printf 'Installed: %s\n' "$target"
done
