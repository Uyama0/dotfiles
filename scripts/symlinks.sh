#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

find "$DOTFILES_DIR" -type f -name '*.link' | while read -r linkfile; do
  while IFS= read -r line || [ -n "$line" ]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    
    IFS='=' read -r src tgt <<< "$line"
    
    src="${src%"${src##*[![:space:]]}"}"
    tgt="${tgt#"${tgt%%[![:space:]]*}"}"

    src="${src/\$DOTFILES/$DOTFILES_DIR}"
    
    eval src_expanded="$src"
    eval tgt_expanded="$tgt"

    if [ -e "$tgt_expanded" ] || [ -L "$tgt_expanded" ]; then
      rm -rf "$tgt_expanded"
    fi

    mkdir -p "$(dirname "$tgt_expanded")"
    ln -s "$src_expanded" "$tgt_expanded"
  done < "$linkfile"
done