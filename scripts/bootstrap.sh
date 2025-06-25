#!/usr/bin/env bash

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCRIPTS=(
  "brew.sh"       # homebrew install
  "symlinks.sh"    # symlinks creation
)

for script in "${SCRIPTS[@]}"; do
  script_path="$DIR/$script"

  if [ -f "$script_path" ]; then
    chmod +x "$script_path"  
    
    if ./"$script"; then
      echo "$script installed"
    else
      echo "$script is not installed" >&2
      exit 1
    fi
  fi

  echo "$script_path"

done