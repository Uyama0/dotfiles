#!/usr/bin/env bash
# Creates symlinks described in */*.link files under ROOT (first arg, default: repo root).
# The work/ layer is skipped unless ROOT points into it.
# Each line: <source>=<target>, $DOTFILES and $HOME are expanded.
# Existing files are moved to unique backups; missing sources fail before any changes.

set -euo pipefail

DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
ROOT="${1:-$DOTFILES}"

skip=()
[ "$ROOT" = "$DOTFILES" ] && skip=(-not -path "$DOTFILES/work/*")

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  echo "$s"
}

expand() {
  local p
  p="$(trim "$1")"
  p="${p//\$DOTFILES/$DOTFILES}"
  p="${p//\$HOME/$HOME}"
  p="${p/#\~/$HOME}"
  echo "$p"
}

# Preflight every source before touching existing configs.
find "$ROOT" -name '*.link' -not -path '*/.git/*' ${skip[@]+"${skip[@]}"} | sort | while IFS= read -r linkfile; do
  while IFS='=' read -r src tgt || [ -n "$src" ]; do
    [[ -z "${src// }" || "$src" =~ ^[[:space:]]*# ]] && continue
    src="$(expand "$src")"
    tgt="$(expand "$tgt")"
    [ -n "$src" ] && [ -n "$tgt" ] && [ -e "$src" ] || {
      echo "error   invalid link or missing source in $linkfile: $src" >&2
      exit 1
    }
  done < "$linkfile"
done

find "$ROOT" -name '*.link' -not -path '*/.git/*' ${skip[@]+"${skip[@]}"} | sort | while IFS= read -r linkfile; do
  while IFS='=' read -r src tgt || [ -n "$src" ]; do
    [[ -z "${src// }" || "$src" =~ ^[[:space:]]*# ]] && continue

    src="$(expand "$src")"
    tgt="$(expand "$tgt")"

    if [ "$(readlink "$tgt" 2>/dev/null)" = "$src" ]; then
      echo "ok      $tgt"
      continue
    fi

    if [ -e "$tgt" ] || [ -L "$tgt" ]; then
      backup="$tgt.backup"
      i=1
      while [ -e "$backup" ] || [ -L "$backup" ]; do
        backup="$tgt.backup.$i"
        i=$((i + 1))
      done
      mv "$tgt" "$backup"
      echo "backup  $tgt -> $backup"
    fi

    mkdir -p "$(dirname "$tgt")"
    ln -s "$src" "$tgt"
    echo "linked  $tgt -> $src"
  done < "$linkfile"
done
