# Uyama dotfiles

## New Mac setup

```sh
xcode-select --install                       # git + make
git clone https://github.com/Uyama0/dotfiles ~/Desktop/projects/dotfiles
cd ~/Desktop/projects/dotfiles

make brew      # Homebrew + everything from Brewfile (log into App Store first for mas apps)
make secrets   # creates ~/.secrets.zsh from template — fill in the values
make links     # symlink configs into $HOME (existing files are moved to *.backup)
make node      # node via nvm + global npm packages (claude-code, claude-code-router, ...)
make vscode    # VS Code extensions
make macos     # Dock / Finder / trackpad settings
make work      # work layer (see below)
```

`make all` does everything above except `work`, `make help` lists commands,
`make dump` shows what is installed on this Mac but missing in the repo.

## What's inside

| Folder | Goes to |
|---|---|
| `zsh/` | `~/.zshrc`, `~/.zprofile` (+ `aliases.zsh`) |
| `git/` | `~/.gitconfig`, `~/.config/git/ignore` |
| `ghostty/` | `~/.config/ghostty/config` |
| `vscode/` | `settings.json`, `extensions.txt` |
| `claude/` | `~/.claude/` settings, CLAUDE.md, RTK.md |
| `k9s/`, `docker/` | k9s aliases/config, docker `daemon.json` |
| `node/` | node version + global packages |
| `macos/` | `defaults write` settings |
| `secrets/` | `secrets.example.zsh` — template for `~/.secrets.zsh` |

## Work layer

Work-specific config lives in `work/` — a separate private repo, ignored here.
Personal configs pick it up if present:

- `~/.zshrc` / `~/.zprofile` source `~/.zshrc.work` / `~/.zprofile.work`
- `~/.gitconfig` includes `~/.gitconfig.work` (user identity)

`make work` installs `work/Brewfile`, links `work/**/*.link`, registers MCP servers.

## Secrets

All tokens/passwords live in `~/.secrets.zsh` (chmod 600, outside the repo),
sourced from `~/.zprofile`. Configs reference them as `$VAR` / `${VAR}`.
Move this file to the new Mac manually (password manager, AirDrop) — never commit it.

## Manual steps on a new Mac

- SSH keys (`~/.ssh/id_*`) — copy or generate new ones
- keyboard layouts

## Adding a new config

Put the config into its own folder and add a `*.link` file next to it:

```
$DOTFILES/<folder>/<file>=$HOME/<target path>
```

Then run `make links` (or `make work` for files under `work/`).
