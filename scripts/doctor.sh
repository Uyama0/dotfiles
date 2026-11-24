#!/usr/bin/env bash
# Read-only migration checks. Never prints credentials or sources secret files.
set -euo pipefail
DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
warnings=0
warn() { echo "WARN  $*"; warnings=$((warnings + 1)); }
ok() { echo "OK    $*"; }

for cmd in git make brew; do
  if command -v "$cmd" >/dev/null 2>&1; then ok "$cmd available"; else warn "$cmd missing"; fi
done
if xcode-select -p >/dev/null 2>&1; then ok "Xcode command line tools"; else warn "run xcode-select --install"; fi
code="$(command -v code || true)"
code="${code:-/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code}"
if [ -x "$code" ]; then ok "VS Code CLI"; else warn "VS Code CLI missing (make brew installs VS Code)"; fi

for name in .zprofile .zshrc; do
  expected="$DOTFILES/zsh/${name#.}"
  if [ "$(readlink "$HOME/$name" || true)" = "$expected" ]; then
    ok "~/$name linked"
  else
    warn "~/$name differs from repo link; compare before make links"
  fi
done

if [ -f "$HOME/.secrets.zsh" ]; then ok "~/.secrets.zsh exists; transfer privately"; else warn "~/.secrets.zsh missing; restore real values before make work"; fi
if [ -f "$DOTFILES/work/Brewfile" ]; then
  ok "work layer present"
  if git -C "$DOTFILES/work" rev-parse --show-toplevel 2>/dev/null | /usr/bin/grep -qxF "$DOTFILES/work"; then
    if ! git -C "$DOTFILES/work" rev-parse --verify HEAD >/dev/null 2>&1; then warn "work repo has no commits; save it before replacing laptop"; fi
    if [ -z "$(git -C "$DOTFILES/work" remote)" ]; then warn "work repo has no remote; copy work/ privately or push to a private repo"; fi
    if [ -n "$(git -C "$DOTFILES/work" status --porcelain)" ]; then warn "work repo has uncommitted files"; fi
  else
    warn "work/ is not a separate repository; copy it privately"
  fi
else
  warn "work layer missing; restore work/ before make work"
fi
if [ -n "$(git -C "$DOTFILES" status --porcelain)" ]; then warn "dotfiles has uncommitted changes; commit/push or transfer the entire directory"; fi

echo
echo "Local state outside Git — transfer privately if needed:"
for name in .ssh .kube .config/rclone .continue .gitlab-token raiffeisen-ca.pem Documents/raif_cert.cer .codex .agents .claude.json .claude .config/opencode .config/kilo .kimi .docker/contexts; do
  if [ -e "$HOME/$name" ]; then echo "COPY  ~/$name"; fi
done
echo
echo "$warnings warning(s). See README.md for the migration checklist."
if [ "$warnings" -gt 0 ]; then exit 1; fi
