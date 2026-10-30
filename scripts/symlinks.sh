#!/usr/bin/env bash
# Creates symlinks described in */*.link files under ROOT (first arg, default: repo root).
# The work/ layer is skipped unless ROOT points into it.
# Each line: <source>=<target>, $DOTFILES and $HOME are expanded.
# Existing files at the target are moved to <target>.backup.

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

find "$ROOT" -name '*.link' -not -path '*/.git/*' ${skip[@]+"${skip[@]}"} | sort | while read -r linkfile; do
  while IFS='=' read -r src tgt || [ -n "$src" ]; do
    [[ -z "${src// }" || "$src" =~ ^[[:space:]]*# ]] && continue

    src="$(expand "$src")"
    tgt="$(expand "$tgt")"

    if [ "$(readlink "$tgt" 2>/dev/null)" = "$src" ]; then
      echo "ok      $tgt"
      continue
    fi

    if [ -e "$tgt" ] || [ -L "$tgt" ]; then
      mv "$tgt" "$tgt.backup"
      echo "backup  $tgt -> $tgt.backup"
    fi

    mkdir -p "$(dirname "$tgt")"
    ln -s "$src" "$tgt"
    echo "linked  $tgt -> $src"
  done < "$linkfile"
done
